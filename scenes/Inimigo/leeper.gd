extends Inimigo

enum { PERSEGUINDO, DORMINDO }
var estado_atual = PERSEGUINDO
@export var delay_pulo : float = 0.04 
var timer_pulo : float = 0.0

# A "memória" do Leeper para evitar o vai e vem
var ultima_direcao : Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if voando or pearl or not atualizar:
		super(delta)
		return

	if estado_atual == DORMINDO:
		return

	if not is_moving:
		timer_pulo += delta
		if timer_pulo >= delay_pulo:
			decidir_direcao_leeper()
			timer_pulo = 0.0
			
	if jogador and global_position.distance_to(jogador.global_position) < 20:
		cair_no_sono()

func decidir_direcao_leeper():
	if not jogador: return
	
	var diff = jogador.global_position - global_position
	
	# 1. Criamos a lista de prioridades:
	# Primeiro as que levam ao Lolo, depois as laterais, e por ÚLTIMO a direção contrária.
	var direcoes_tentativas = []

	# Adiciona as que aproximam do Lolo
	if abs(diff.x) > abs(diff.y):
		direcoes_tentativas.append(Vector2(sign(diff.x), 0))
		direcoes_tentativas.append(Vector2(0, sign(diff.y)))
	else:
		direcoes_tentativas.append(Vector2(0, sign(diff.y)))
		direcoes_tentativas.append(Vector2(sign(diff.x), 0))
	
	# Adiciona as outras direções que faltam na lista
	for d in [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]:
		if d not in direcoes_tentativas:
			direcoes_tentativas.append(d)

	# 2. Filtro de Inteligência: 
	# Vamos mover a direção "oposta" à que estamos indo para o fim da lista.
	# Isso evita que ele volte para trás se houver QUALQUER outra opção.
	var direcao_oposta = -ultima_direcao
	if direcao_oposta != Vector2.ZERO:
		direcoes_tentativas.erase(direcao_oposta)
		direcoes_tentativas.append(direcao_oposta) # Joga pro final da fila

	# 3. Tenta se mover seguindo a nova ordem de prioridade
	for dir in direcoes_tentativas:
		if dir != Vector2.ZERO:
			if not checar_obstaculo(dir):
				ultima_direcao = dir # Salva a direção para a próxima decisão
				update_animation(dir)
				mover_inimigo(dir)
				return # Sai da função assim que conseguir se mover

func atualizar_direcao_do_olhar():
	pass

func update_animation(direction):
	if direction == Vector2.RIGHT: anima.play("walk_right")
	elif direction == Vector2.LEFT: anima.play("walk_left")
	elif direction == Vector2.DOWN: anima.play("walk_down")
	elif direction == Vector2.UP: anima.play("walk_up")

func checar_obstaculo(dir: Vector2) -> bool:
	ray.target_position = dir * tile_size
	ray.force_raycast_update()
	return ray.is_colliding()
	
func cair_no_sono():
	estado_atual = DORMINDO
	is_moving = false
	anima.play("idle")
