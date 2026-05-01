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
	print("Tiro atingiu: ", body.name)
	if body.has_method("tomar_tiro"):
		if alinhado(body):
			# Calculamos a direção aqui e enviamos para o inimigo
			var dir_impacto = (body.global_position - global_position).normalized()
			body.tomar_tiro(dir_impacto)
			queue_free()
		else:
			return
	# Se bater em uma parede (TileMap) ou inimigo, o tiro some
	queue_free()

func alinhado(alvo) -> bool:
	# Se movemos na horizontal (esquerda/direita), checamos se o Y é igual
	if direcao.x != 0:
		return abs(position.y - alvo.position.y) < 2.0 # Margem de erro de 2 pixels
	
	# Se movemos na vertical (cima/baixo), checamos se o X é igual
	if direcao.y != 0:
		return abs(position.x - alvo.position.x) < 2.0
		
	return false
