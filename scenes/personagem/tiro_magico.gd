extends Area2D

@export var velocidade = 150 # Velocidade do projétil
var direcao = Vector2.ZERO

func set_direcao(dir: Vector2):
	direcao = dir
	
	# Ajusta a animação baseada na direção recebida
	if dir == Vector2.UP: $AnimatedSprite2D.play("tiro_up")
	elif dir == Vector2.DOWN: $AnimatedSprite2D.play("tiro_down")
	elif dir == Vector2.LEFT: $AnimatedSprite2D.play("tiro_left")
	elif dir == Vector2.RIGHT: $AnimatedSprite2D.play("tiro_right")

func _physics_process(delta):
	# Movimento linear simples
	position += direcao * velocidade * delta

# Conecte o sinal 'body_entered' da Area2D a esta função
func _on_body_entered(body: Node2D) -> void:
	# Se bater em uma parede (TileMap) ou inimigo, o tiro some
	print("Tiro atingiu: ", body.name)
	queue_free()
