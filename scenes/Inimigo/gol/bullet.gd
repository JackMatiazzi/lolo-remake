extends Area2D

@export var velocidade = 150
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
	# 1. ANULAÇÃO IMEDIATA
	# Desativa o monitoramento para que o sinal 'body_entered' não dispare de novo
	set_deferred("monitoring", false) 
	# Zera a velocidade para o impacto ser no lugar certo
	velocidade = 0 
	
	print("Tiro atingiu: ", body.name)
	
	# 2. EXECUÇÃO DA LÓGICA
	_bateu(direcao)
	
	# Se o alvo for destrutível, chama a morte dele
	if body.has_method("executar_morte"):
		body.executar_morte()
	
	# 3. ESPERA A ANIMAÇÃO
	# Espera o tiro "explodir" antes de sumir
	await $AnimatedSprite2D.animation_finished
	
	# 4. LIMPEZA
	queue_free()
