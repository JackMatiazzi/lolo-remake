extends Inimigo

@export var bullet_scene : PackedScene
@export var direcao = Vector2.ZERO
var bala_atual = null
var bateu := false
var acordado = false

func atualizar_direcao_do_olhar():
	pass

func _physics_process(delta):
	if voando:
		velocity = velocidade_morte
		move_and_slide()
		return
	
	if bateu:
		return
	_sentinela()

func _on_level_todos_coletados():
	acordado = true
	set_animecao(direcao)

func _sentinela():
	if bala_atual != null:
		return
	set_animecao(direcao)
	ray.target_position = direcao * (tile_size * 84) 
	
	if ray.is_colliding() and ray.get_collider() == jogador:
		if acordado:
			_atirar()
	
func _atirar():

	if abs(jogador.global_position.x - global_position.x) < 8:
		if jogador.global_position.y > global_position.y:
			direcao = Vector2.DOWN
		else:
			direcao = Vector2.UP

	elif abs(jogador.global_position.y - global_position.y) < 8:
		if jogador.global_position.x > global_position.x:
			direcao = Vector2.RIGHT
		else:
			direcao = Vector2.LEFT

	var bala = bullet_scene.instantiate()
	bala.global_position = global_position + direcao * 8
	bala.set_direcao(direcao)

	bala_atual = bala
	bala.tree_exited.connect(_on_bala_sumiu)
	get_tree().current_scene.add_child(bala)
	
func _on_bala_sumiu():
	bala_atual = null
	
func set_animecao(dir: Vector2):
	direcao = dir
	if acordado:
		# Ajusta a animação baseada na direção recebida
		if dir == Vector2.UP: $AnimatedSprite2D.play("up_acordado")
		elif dir == Vector2.DOWN: $AnimatedSprite2D.play("down_acordado")
		elif dir == Vector2.LEFT: $AnimatedSprite2D.play("left_acordado")
		elif dir == Vector2.RIGHT: $AnimatedSprite2D.play("right_acordado")
	else:
		if dir == Vector2.UP: $AnimatedSprite2D.play("up")
		elif dir == Vector2.DOWN: $AnimatedSprite2D.play("down")
		elif dir == Vector2.LEFT: $AnimatedSprite2D.play("left")
		elif dir == Vector2.RIGHT: $AnimatedSprite2D.play("right")
