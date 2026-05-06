extends Inimigo

@export var bullet_scene : PackedScene
@export var direcao = Vector2.ZERO
@onready var ray_lolo: RayCast2D = $RayCast2D2
var bala_atual = null
var bateu := false
var acordado = false

func _ready() -> void:
	var diff = jogador.global_position - global_position
	# Verificamos qual distância é maior para decidir se ele olha 
	# horizontalmente ou verticalmente
	if abs(diff.x) > abs(diff.y):
		# Lolo está mais longe nos lados
		direcao = Vector2.RIGHT if diff.x > 0 else Vector2.LEFT
	else:
		# Lolo está mais longe em cima ou baixo
		direcao = Vector2.DOWN if diff.y > 0 else Vector2.UP

func atualizar_direcao_do_olhar():
	pass

func _physics_process(delta):
	if voando:
		velocity = velocidade_morte
		move_and_slide()
		return
		
	if pearl:
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
	ray_lolo.target_position = direcao * (tile_size * 84) 
	
	if ray_lolo.is_colliding() and ray_lolo.get_collider() == jogador:
		if acordado:
			_atirar(direcao)
	
func _atirar(dir):
	var bala = bullet_scene.instantiate()
	bala.global_position = global_position + dir * 4
	bala.set_direcao(direcao)

	bala_atual = bala
	bala_atual.tree_exited.connect(_on_bala_sumiu)
	get_tree().current_scene.add_child(bala)
	
func _on_bala_sumiu():
	bala_atual = null
	
func set_animecao(dir: Vector2):
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
	direcao = dir
