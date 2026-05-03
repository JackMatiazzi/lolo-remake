extends CharacterBody2D
class_name Inimigo

@export var tile_size = 8
@export var walk_speed = 0.1

@onready var ray: RayCast2D = $RayCast2D
@onready var anima: AnimatedSprite2D = $AnimatedSprite2D
@onready var jogador = get_tree().get_first_node_in_group("personagem")

var is_moving = false
var atualizar = true
var pearl = false
var voando = false
var velocidade_morte: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if voando:
		# Aplica a velocidade de morte
		velocity = velocidade_morte
		move_and_slide()
		return

	if pearl:
		return
	
	if atualizar:
		atualizar_direcao_do_olhar()
	else:
		if not pearl:
			anima.play("idle")
	
func _on_level_todos_coletados():
	atualizar = false

func atualizar_direcao_do_olhar():
	anima.animation = "idle"
	var direcao = jogador.global_position - global_position
	var angulo = rad_to_deg(direcao.angle())
	
	if angulo > -20 and angulo <= 20:
		anima.frame = 3 # Direita
	elif angulo > 160 or angulo <= -160:
		anima.frame = 0 # Esquerda
	elif direcao.x > 0:
		anima.frame = 2 # Meio Direita
	else:
		anima.frame = 1 # Meio Esquerda

func tomar_tiro(direcao_do_tiro: Vector2):
	if voando:
		return

	if pearl:
		voando = true
		
		collision_layer = 0 # Para de ser um obstáculo
		collision_mask = 0  # Para de bater em paredes
		# -----------------------------
		# Se a direção do tiro vier zerada por erro, definimos uma padrão
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
	
func mover_inimigo(direction):
	is_moving = true
	var target_position = position + (direction * tile_size)
	var tween = create_tween()
	tween.tween_property(self, "position", target_position, walk_speed)
	tween.finished.connect(func(): is_moving = false)
