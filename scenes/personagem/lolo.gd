extends CharacterBody2D

# --- VARIÁVEIS ---
@export var tile_size = 8
@export var walk_speed = 0.1
@export var tiros_disponiveis = 0: 
	set(valor):
		tiros_disponiveis = valor
		disparos_atualizados.emit(tiros_disponiveis)

@onready var anim = $AnimatedSprite2D
@onready var idle_timer = $IdleTimer
@onready var ray = $RayCast2D

signal disparos_atualizados(quantidade)
signal jogador_morreu

var ultima_direcao = Vector2.DOWN
var cena_tiro = preload("res://scenes/personagem/tiro_magico.tscn")
var morreu = false
var venceu = false
var is_moving = false
var is_idle = false


func _physics_process(_delta):
	# 1. PRIORIDADE MÁXIMA: MORTE
	# Se morreu ou venceu, nada mais importa.
	if morreu or venceu:
		return
	
	# 2. SEGUNDA PRIORIDADE: TIRO
	# Colocamos aqui para que ele possa atirar MESMO EM MOVIMENTO.
	# Usamos 'just_pressed' para evitar gasto infinito de munição.
	if Input.is_action_just_pressed("ui_accept"):
		atirar()
	
	# 3. COMANDO DE DEBUG/MORTE
	if Input.is_key_pressed(KEY_SHIFT):
		executar_morte()
		return
	
	# 4. BLOQUEIO DE MOVIMENTO
	# Agora o 'return' só impede novos comandos de andar, mas não impede o tiro acima.
	if is_moving:
		return
		
	# 5. PROCESSAMENTO DE DIREÇÃO
	var input_dir = get_input_direction()
	
	if input_dir != Vector2.ZERO:
		# Se o jogador apertar qualquer tecla, para o contador de Idle
		is_idle = false
		idle_timer.stop()
		ultima_direcao = input_dir
		 
		# --- VERIFICAÇÃO DE COLISÃO ANTES DE MOVER ---
		var obstaculo = check_collision(input_dir)
		if obstaculo == null:
			# Caminho livre, pode mover
			move_in_grid(input_dir)
		else:
			# Bateu em algo! Vamos ver se é um bloco empurrável
			processar_colisao(obstaculo, input_dir)
	else:
		if not is_idle:
			anim.stop();

# --- FUNÇÕES AUXILIARES DE INPUT ---

func get_input_direction() -> Vector2:
	# O get_vector lê (esquerda, direita, cima, baixo)
	# Ele retorna um Vector2 que já lida com teclas opostas se anulando
	var input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Em jogos de grade (Sokoban), não podemos andar na diagonal.
	# Então, priorizamos o eixo com maior "força" de aperto:
	if abs(input.x) > abs(input.y):
		return Vector2(sign(input.x), 0) # Retorna apenas Direita ou Esquerda
	elif abs(input.y) > 0:
		return Vector2(0, sign(input.y)) # Retorna apenas Cima ou Baixo
		
	return Vector2.ZERO

# --- LOGICA DE MUNDO ---

func check_collision(direction):
	ray.position = direction * 4
	ray.target_position = direction * (tile_size - 4)
	
	# Fazemos um teste rápido para ver se há um inimigo aqui
	ray.hit_from_inside = true # Começamos falso para não nos prendermos
	ray.force_raycast_update()
	
	if ray.is_colliding():
		var colisor = ray.get_collider()
		if colisor.is_in_group("inimigo"):
			var distancia = global_position.distance_to(colisor.global_position)
			
			# SE estiver no CENTRO EXATO (menos de 2 pixels de distância)
			if distancia < 2.0:
				# DESATIVAMOS o Hit From Inside e ignoramos este inimigo específico
				# para permitir que o RayCast aponte para fora sem bater em nada.
				ray.hit_from_inside = false
				ray.add_exception(colisor)
	
	# 2. Agora executamos o teste real com as configurações ajustadas
	ray.force_raycast_update()
	var resultado = ray.get_collider() if ray.is_colliding() else null
	
	# Limpamos as exceções para o próximo frame
	ray.clear_exceptions()
	
	return resultado

func processar_colisao(obstaculo, input_dir):
	# Encapsulamos a lógica do bloco para limpar o physics_process
	if obstaculo.has_method("empurrar") and alinhado(obstaculo, input_dir):
		if obstaculo.empurrar(input_dir):
			move_in_grid(input_dir)
		else:
			update_animation(input_dir)
	else:
		update_animation(input_dir)
	
func alinhado(objeto, direcao_movimento) -> bool:
	# Se movemos na horizontal (esquerda/direita), checamos se o Y é igual
	if direcao_movimento.x != 0:
		return abs(position.y - objeto.position.y) < 2.0 # Margem de erro de 2 pixels
	
	# Se movemos na vertical (cima/baixo), checamos se o X é igual
	if direcao_movimento.y != 0:
		return abs(position.x - objeto.position.x) < 2.0
		
	return false

func move_in_grid(direction):
	is_moving = true
	update_animation(direction)
	
	var target_position = position + (direction * tile_size)
	var tween = create_tween()
	tween.tween_property(self, "position", target_position, walk_speed)
	
	tween.finished.connect(func(): 
		is_moving = false
		# Ao parar de mover, o timer de idle começa a contar novamente
		idle_timer.start()
	)

func update_animation(direction):
	if direction == Vector2.RIGHT: anim.play("walk_right")
	elif direction == Vector2.LEFT: anim.play("walk_left")
	elif direction == Vector2.DOWN: anim.play("walk_down")
	elif direction == Vector2.UP: anim.play("walk_up")
	
# --- AÇÕES E EVENTOS ---

func atirar():
	# Só atira se tiver munição e não estiver na animação de morte
	if tiros_disponiveis > 0 and not morreu:
		tiros_disponiveis -= 1
		is_idle = false # Atirar quebra o estado de idle
		update_animation(ultima_direcao)
		
		var tiro_instancia = cena_tiro.instantiate()
		tiro_instancia.position = self.position
		tiro_instancia.set_direcao(ultima_direcao)
		get_tree().current_scene.add_child(tiro_instancia)
	else:
		print("Sem munição!")

func executar_morte():
	morreu = true
	is_moving = true
	# 1. Esconde o Baú (usando grupo para segurança)
	get_tree().call_group("bau", "set_visible", false)
	# 2. Apaga o Spawner para ele não criar novos inimigos enquanto o Lolo morre
	get_tree().call_group("spawner", "queue_free")
	anim.play("die")

func executar_vitoria():
	venceu = true
	is_moving = true
	anim.play("victory")    # Toca a animação de comemoração

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "die":
		jogador_morreu.emit()
	# Quando a dança da vitória acabar:
	elif anim.animation == "victory":
		GameMaster.proxima_fase() # O Player avisa que pode mudar de cena
		#get_tree().quit()

func _on_idle_timer_timeout():
	if not is_moving:
		is_idle = true
		anim.play("idle")

func _on_sensor_area_entered(area: Area2D) -> void:
	var alvo = null
	if area.get_parent().has_method("coletar"):
		alvo = area.get_parent()
	if alvo:
		var ganhou_tiro = alvo.coletar()
		if ganhou_tiro:
			tiros_disponiveis += 2
