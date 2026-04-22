extends CharacterBody2D

@export var tile_size = 8
@export var walk_speed = 0.1
@export var idle_wait_time = 2.0 # Tempo para ficar idle

@onready var anim = $AnimatedSprite2D
@onready var idle_timer = $IdleTimer # Arraste o nó Timer para 

signal jogador_morreu

@onready var ray = $RayCast2D # Referência ao laser de colisão

var morreu:= false
var is_moving = false
var is_idle = false

func _ready():
	jogador_morreu.connect(GameMaster._ao_morrer)
	idle_timer.wait_time = idle_wait_time
	idle_timer.one_shot = true
	idle_timer.start() # Começa a contar assim que o jogo inicia
	

func _physics_process(_delta):
	if is_moving:
		return
	if morreu:
		return
	
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("ui_right"): input_dir = Vector2.RIGHT
	elif Input.is_action_pressed("ui_left"): input_dir = Vector2.LEFT
	elif Input.is_action_pressed("ui_down"): input_dir = Vector2.DOWN
	elif Input.is_action_pressed("ui_up"): input_dir = Vector2.UP
	
	if Input.is_key_pressed(KEY_SHIFT):
		morreu = true
		is_moving = true    # trava movimento junto
		anim.play("die")
		return              # não processa mais nada 

	if input_dir != Vector2.ZERO:
		# Se o jogador apertar qualquer tecla, para o contador de Idle
		is_idle = false
		idle_timer.stop()
		 
		# --- VERIFICAÇÃO DE COLISÃO ANTES DE MOVER ---
		var obstaculo = check_collision(input_dir)
		if obstaculo == null:
			# Caminho livre, pode mover
			move_in_grid(input_dir)
		else:
			# Bateu em algo! Vamos ver se é um bloco empurrável
			if obstaculo.has_method("empurrar"):
				if alinhado(obstaculo, input_dir):
					# Tenta empurrar. Se o bloco retornar TRUE, ele moveu.
					if obstaculo.empurrar(input_dir):
						move_in_grid(input_dir) # Player move atrás do bloco
					else:
						# Bloco não pode mover (bateu em parede), apenas vira o player
						update_animation(input_dir)
				else:
					# Não é bloco (é parede ou tilemap sólido), apenas vira o player
					update_animation(input_dir)
			else:
				# Não é bloco (é parede ou tilemap sólido), apenas vira o player
				update_animation(input_dir)
	else:
		if not is_idle:
			anim.stop();

# Função para checar se o próximo tile está ocupado
func check_collision(direction):
	# Aponta o RayCast para a direção do movimento
	ray.target_position = direction * tile_size
	# Força o RayCast a atualizar a posição imediatamente
	ray.force_raycast_update()
	# Retorna se o laser bater em algo (StaticBody2D, TileMap, etc)
	if ray.is_colliding():
		return ray.get_collider()
	return null
	
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
	
# --- CONECTE O SINAL 'timeout()' DO IDLE_TIMER A ESTA FUNÇÃO ---
func _on_idle_timer_timeout():
	# Só toca o idle se ele não estiver no meio de um movimento
	if not is_moving:
		is_idle = true
		anim.play("idle") # Certifique-se de ter uma animação chamada "idle"
		print("Personagem ficou entediado e entrou em Idle")


func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "die":
		morreu = false
		is_moving = false
		emit_signal("jogador_morreu")

func _on_sensor_area_entered(area: Area2D) -> void:
	# 1. Procuramos a função 'coletar' na própria área ou no pai dela
	var alvo = null
	
	if area.get_parent().has_method("coletar"):
		alvo = area.get_parent()
	
	# 2. Se encontramos algo coletável, executamos a ação
	if alvo:
		fazer_coleta(alvo)
		
func fazer_coleta(objeto):
	# Chamamos a função e recebemos o booleano (True se for tiro mágico, False se não)
	var ganhou_tiro = objeto.coletar()
	
	if ganhou_tiro:
		print("Poder de tiro ativado!")
		# Aqui você ativaria a variável de tiro do seu Player
	else:
		# Se for o baú ou item comum, ele entra aqui.
		print("Item coletado com sucesso.")
