extends CharacterBody2D
class_name Inimigo

@export var tile_size = 16
@export var walk_speed = 0.7
@export var tempo_entre_passos = 0.6

@onready var ray: RayCast2D = $RayCast2D
@onready var anima: AnimatedSprite2D = $AnimatedSprite2D
@onready var jogador = get_tree().get_first_node_in_group("personagem")

var is_moving = false
var atualizar = true
var pearl = false
var voando = false
var velocidade_morte: Vector2 = Vector2.ZERO

var direcao_atual = Vector2.RIGHT
var direcoes = [
	Vector2.RIGHT,
	Vector2.LEFT,
	Vector2.UP,
	Vector2.DOWN
]

func _ready():
	randomize()
	ciclo_movimento()

func _physics_process(delta: float) -> void:
	if voando:
		velocity = velocidade_morte
		move_and_slide()
		return

func ciclo_movimento():
	while true:
		await get_tree().create_timer(tempo_entre_passos).timeout
		
		if voando or pearl:
			continue
			
		tentar_andar()

func tentar_andar():
	if is_moving:
		return
	
	if pode_andar(direcao_atual):
		mover_inimigo(direcao_atual)
		atualizar_animacao_movimento(direcao_atual)
		return
	
	var direcoes_embaralhadas = direcoes.duplicate()
	direcoes_embaralhadas.shuffle()
	
	for direcao in direcoes_embaralhadas:
		if pode_andar(direcao):
			direcao_atual = direcao
			mover_inimigo(direcao)
			atualizar_animacao_movimento(direcao)
			return
	
	anima.play("idle")

func pode_andar(direction: Vector2) -> bool:
	ray.target_position = direction * (tile_size + 2)
	ray.force_raycast_update()
	
	return not ray.is_colliding()

func mover_inimigo(direction):
	is_moving = true
	
	var target_position = position + (direction * tile_size)
	
	var tween = create_tween()
	tween.tween_property(self, "position", target_position, walk_speed)
	tween.finished.connect(func(): is_moving = false)

func atualizar_animacao_movimento(direcao: Vector2):
	if direcao == Vector2.RIGHT:
		anima.play("walking_right")
	elif direcao == Vector2.LEFT:
		anima.play("walking_left")
	elif direcao == Vector2.UP:
		anima.play("walking_up")
	elif direcao == Vector2.DOWN:
		anima.play("walking_down")

func _on_level_todos_coletados():
	atualizar = false

func atualizar_direcao_do_olhar():
	anima.animation = "idle"
	var direcao = jogador.global_position - global_position
	var angulo = rad_to_deg(direcao.angle())
	
	if angulo > -20 and angulo <= 20:
		anima.frame = 3
	elif angulo > 160 or angulo <= -160:
		anima.frame = 0
	elif direcao.x > 0:
		anima.frame = 2
	else:
		anima.frame = 1

func tomar_tiro(direcao_do_tiro: Vector2):
	if voando:
		return

	if pearl:
		voando = true
		
		collision_layer = 0
		collision_mask = 0
		
		if direcao_do_tiro == Vector2.ZERO:
			direcao_do_tiro = Vector2.UP 
			
		velocidade_morte = direcao_do_tiro.normalized() * 300.0
	else:
		virar_pearl()

func virar_pearl():
	pearl = true
	anima.play("pearl")

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_animated_sprite_2d_animation_finished() -> void:
	if anima.animation == "pearl":
		if not voando:
			pearl = false

func empurrar(direction: Vector2) -> bool:
	if is_moving or not pearl:
		return false

	ray.target_position = direction * tile_size
	ray.force_raycast_update()
	
	if ray.is_colliding():
		return false
	
	mover_inimigo(direction)
	return true
