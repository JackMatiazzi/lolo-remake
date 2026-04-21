extends CharacterBody2D

@onready var anima: AnimatedSprite2D = $AnimatedSprite2D
@onready var colide: CollisionShape2D = $CollisionShape2D

var jogador : Node2D
var pearl: bool = false

func _ready() -> void:
	jogador = get_tree().get_first_node_in_group("personagem")	
	#add_to_group("personagem")
	
func _process(_delta: float) -> void:
	if jogador == null:
		return
	
	var direcao = jogador.global_position - global_position
	var angulo = rad_to_deg(direcao.angle())
	
	if angulo >= -22.5 and angulo < 22.5:
		anima.play("direita")
	elif angulo >= 22.5 and angulo < 67.5:
		anima.play("meio_direita")
	elif angulo >= 67.5 and angulo < 112.5:
		anima.play("frente_direita")
	elif angulo >= 112.5 and angulo < 157.5:
		anima.play("frente_esquerda")
	elif angulo >= 157.5 or angulo < -157.5:
		anima.play("esquerda")
	elif angulo >= -157.5 and angulo < -112.5:
		anima.play("meio_esquerda")
	elif angulo >= -112.5 and angulo < -67.5:
		anima.play("frente_direita")
	elif angulo >= -67.5 and angulo < -22.5:
		anima.play("meio_direita")
		
		
