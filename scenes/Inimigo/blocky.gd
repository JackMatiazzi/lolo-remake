extends Inimigo

enum { PATRULHANDO, PERSEGUINDO, PARADO }
var estado_atual = PATRULHANDO

@export var delay_patrulha : float = 0.15
@export var delay_perseguicao : float = 0.08
@export var distancia_bloqueio : float = 20 

var ordem_direcoes = [Vector2.DOWN, Vector2.LEFT, Vector2.UP, Vector2.RIGHT]
var indice_direcao_atual = 0 
var timer = 0.0

func _physics_process(delta: float) -> void:
	if voando or pearl or not atualizar:
		super(delta)
		return

	if not is_moving:
		timer += delta
		var delay_atual = delay_perseguicao if estado_atual == PERSEGUINDO else delay_patrulha
		
		if timer >= delay_atual:
			timer = 0.0
			processar_ia_blocky()

func processar_ia_blocky():
	if not jogador: return
	var diff = jogador.global_position - global_position
	var distancia = global_position.distance_to(jogador.global_position)
	
	# --- 1. EXCEÇÃO DE PERSEGUIÇÃO ---
	if estado_atual == PERSEGUINDO:
		if abs(diff.x) >= 8:
			estado_atual = PATRULHANDO
			executar_patrulha_blocky()
		else:
			# Tenta perseguir. Se falhar (bater em parede/Lolo preso), muda para PARADO
			if not executar_perseguicao(diff):
				estado_atual = PARADO
		return

	# --- 2. VALIDAÇÃO DE PARADA (Patrulha) ---
	if distancia < distancia_bloqueio:
		estado_atual = PARADO
		parar_e_olhar(diff)
		return

	# --- 3. LÓGICA DE TRANSIÇÃO ---
	if abs(diff.x) < 8: 
		estado_atual = PERSEGUINDO
		if not executar_perseguicao(diff):
			estado_atual = PARADO
	else:
		estado_atual = PATRULHANDO
		executar_patrulha_blocky()

func executar_perseguicao(diff: Vector2) -> bool:
	walk_speed = delay_perseguicao
	var dir_y = Vector2(0, sign(diff.y))
	
	# Verifica colisão
	if checar_obstaculo(dir_y):
		var colisor = ray.get_collider()
		
		if colisor and colisor.is_in_group("personagem"):
			if colisor.has_method("receber_empurrao"):
				if colisor.receber_empurrao(dir_y):
					executar_movimento(dir_y)
					return true # Moveu empurrando
		
		# Se chegou aqui, colidiu com algo que não pode mover
		anima.stop()
		return false 
	
	# Caminho totalmente livre
	executar_movimento(dir_y)
	return true

func parar_e_olhar(diff):
	anima.stop()
	var dir_olhar = Vector2(0, sign(diff.y)) if abs(diff.y) > abs(diff.x) else Vector2(sign(diff.x), 0)
	update_animation(dir_olhar)

func executar_patrulha_blocky():
	walk_speed = delay_patrulha 
	var dir_atual = ordem_direcoes[indice_direcao_atual]

	if not checar_obstaculo(dir_atual):
		executar_movimento(dir_atual)
	else:
		mudar_direcao_patrulha_circular()

func mudar_direcao_patrulha_circular():
	# EXCEÇÃO 1: Se estava indo para BAIXO (0) e bateu, e a ESQUERDA (1) está bloqueada
	if indice_direcao_atual == 0 and checar_obstaculo(ordem_direcoes[1]): 
		if not checar_obstaculo(ordem_direcoes[3]): # Tenta DIREITA (3)
			indice_direcao_atual = 3
			executar_movimento(ordem_direcoes[3])
			return

	# EXCEÇÃO 2: Se estava indo para CIMA (2) e bateu, e a DIREITA (3) está bloqueada
	if indice_direcao_atual == 2 and checar_obstaculo(ordem_direcoes[3]):
		if not checar_obstaculo(ordem_direcoes[1]): # Tenta ESQUERDA (1)
			indice_direcao_atual = 1
			executar_movimento(ordem_direcoes[1])
			return

	# Lógica Padrão Circular (B -> E -> C -> D)
	for i in range(1, 4):
		var proximo_indice = (indice_direcao_atual + i) % 4
		var dir_teste = ordem_direcoes[proximo_indice]
		if not checar_obstaculo(dir_teste):
			indice_direcao_atual = proximo_indice
			executar_movimento(dir_teste)
			return
			
	# Beco sem saída (Meia-volta)
	var direcao_vinda = (indice_direcao_atual + 2) % 4
	indice_direcao_atual = direcao_vinda
	executar_movimento(ordem_direcoes[indice_direcao_atual])

func executar_movimento(dir: Vector2):
	update_animation(dir)
	mover_inimigo(dir)

func update_animation(direction: Vector2):
	if direction == Vector2.RIGHT: anima.play("walk_right")
	elif direction == Vector2.LEFT: anima.play("walk_left")
	elif direction == Vector2.DOWN: anima.play("walk_down")
	elif direction == Vector2.UP: anima.play("walk_up")

func checar_obstaculo(dir: Vector2) -> bool:
	ray.position = dir * 4
	ray.target_position = dir * (tile_size - 4)
	ray.force_raycast_update()
	return ray.is_colliding()

func atualizar_direcao_do_olhar():
	pass

func _on_level_todos_coletados():
	atualizar = true
