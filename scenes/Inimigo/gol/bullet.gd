extends Area2D

@export var velocidade = 100 
var direcao = Vector2.ZERO

func _physics_process(delta) -> void:
		
	position += direcao * velocidade * delta
	

func set_direcao(dir: Vector2):
	direcao = dir

	if dir == Vector2.UP: $AnimatedSprite2D.play("up")
	elif dir == Vector2.DOWN: $AnimatedSprite2D.play("down")
	elif dir == Vector2.LEFT: $AnimatedSprite2D.play("left")
	elif dir == Vector2.RIGHT: $AnimatedSprite2D.play("right")

func _bateu(dir: Vector2):
	direcao = dir
	
	if dir == Vector2.UP: $AnimatedSprite2D.play("up_bateu")
	elif dir == Vector2.DOWN: $AnimatedSprite2D.play("down_bateu")
	elif dir == Vector2.LEFT: $AnimatedSprite2D.play("left_bateu")
	elif dir == Vector2.RIGHT: $AnimatedSprite2D.play("right_bateu")
	
func _on_body_entered(body: Node2D) -> void:
	print("Tiro atingiu: ", body.name)
	if body.has_method("executar_morte"):
		_bateu(direcao)
		body.executar_morte()
		queue_free()
	_bateu(direcao)
	queue_free()
