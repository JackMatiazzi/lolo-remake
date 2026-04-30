extends CharacterBody2D

@export var tile_size = 8
@export var walk_speed = 0.1

@onready var ray = $RayCast2D
@onready var anima: AnimatedSprite2D = $AnimatedSprite2D
@onready var notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

var jogador: Node2D
var is_moving = false

var pearl: bool = false
var voando: bool = false

var velocidade_voo: Vector2 = Vector2.ZERO

var animacao_atual: String = ""
var posicao_inicial: Vector2
var pode_processar: bool = true

func _ready() -> void:
	jogador = get_tree().get_first_node_in_group("personagem")
	posicao_inicial = global_position
	var bau = get_tree().get_first_node_in_group("bau")
	if bau:
		bau.level_concluido.connect(func(): queue_free())

func _process(delta: float) -> void:
	if not pode_processar:
		return
	
	if jogador == null:
		return

	if voando:
		velocity = velocidade_voo
		move_and_slide()
		return

	if pearl:
		return


	var direcao = jogador.global_position - global_position
	var angulo = rad_to_deg(direcao.angle())

	var nova_animacao := ""

	if angulo > -20 and angulo <= 20:
		nova_animacao = "direita"

	elif angulo > 160 or angulo <= -160:
		nova_animacao = "esquerda"

	elif direcao.x > 0:
		nova_animacao = "meio_direita"
	else:
		nova_animacao = "meio_esquerda"

	if nova_animacao != animacao_atual:
		animacao_atual = nova_animacao
		anima.play(animacao_atual)

func tomar_tiro():
	print("tomar_tiro chamado! voando: ", voando, "pearl: ", pearl)
	if voando:
		return
		
	if pearl:
		morrer_voando()
	else:
		virar_pearl()

func virar_pearl():
	pearl = true
	animacao_atual = ""
	anima.play("pearl")

func morrer_voando():
	voando = true
	
	var direcao = (global_position - jogador.global_position).normalized()
	print("direcao: ", direcao)
	velocidade_voo = direcao * 400
	
func _on_area_2d_area_entered(area):
	print("area detectada:  ", area.name)
	if area.is_in_group("tiro"):
		print("tiro detectado")
		tomar_tiro()
		area.queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	if voando:
		respawn()


func respawn():
	pode_processar = false
	#visible = false
	#set_physics_process(false)
	
	await get_tree().create_timer(10.0).timeout
	

	global_position = posicao_inicial
	velocity = Vector2.ZERO
	velocidade_voo = Vector2.ZERO
	
	pearl = false
	voando = false
	
	#visible = true
	#set_physics_process(true)
	pode_processar = true
	
	animacao_atual = ""
	anima.play("direita") # animação padrão


func _on_animated_sprite_2d_animation_finished() -> void:
	if animacao_atual == "" and pearl and not voando:
		pearl = false
		animacao_atual = "direita"
		anima.play("direita")
		
func empurrar(direction: Vector2) -> bool:
	#if not pearl:
		#return false

	if is_moving:
		return false

		
	ray.target_position = direction * tile_size
	ray.force_raycast_update()
	
	if ray.is_colliding():
		return false
	
	mover_inimigo(direction)
	return true
	
func mover_inimigo(direction):
	is_moving = true
	var target_position = position + (direction * tile_size)
	var tween = create_tween()
	tween.tween_property(self, "position", target_position, walk_speed)
	tween.finished.connect(func(): is_moving = false)
