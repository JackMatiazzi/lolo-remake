extends CharacterBody2D

@onready var anima: AnimatedSprite2D = $AnimatedSprite2D
@onready var notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

var jogador: Node2D

# Estados
var pearl: bool = false
var voando: bool = false

var velocidade_voo: Vector2 = Vector2.ZERO

var animacao_atual: String = ""
var posicao_inicial: Vector2
var pode_processar: bool = true

#func _ready() -> void:
	#jogador = get_tree().get_first_node_in_group("personagem")
	#posicao_inicial = global_position
#
#func _process(delta: float) -> void:
	#if not pode_processar:
		#return
	#
	#if jogador == null:
		#return
#
	#if voando:
		#velocity = velocidade_voo
		#move_and_slide()
		#return
#
	#if pearl:
		#return
#
#
	#var direcao = jogador.global_position - global_position
	#var angulo = rad_to_deg(direcao.angle())
#
	#var nova_animacao := ""
#
	#if angulo > -20 and angulo <= 20:
		#nova_animacao = "direita"
#
	#elif angulo > 160 or angulo <= -160:
		#nova_animacao = "esquerda"
#
	#elif direcao.x > 0:
		#nova_animacao = "meio_direita"
	#else:
		#nova_animacao = "meio_esquerda"
#
	#if nova_animacao != animacao_atual:
		#animacao_atual = nova_animacao
		#anima.play(animacao_atual)

#func tomar_tiro():
	#if voando:
		#return
		#
	#if pearl:
		#morrer_voando()
	#else:
		#virar_pearl()
#
#func virar_pearl():
	#pearl = true
	#anima.play("pearl")
#
#func morrer_voando():
	#voando = true
	#
	#var direcao = (global_position - jogador.global_position).normalized()
	#velocidade_voo = direcao * 400
	#
	#anima.play("pearl")
#
#func _on_area_2d_body_entered(body):
	#if body.is_in_group("tiro"):
		#tomar_tiro()
		#body.queue_free()
#
#func _on_visible_on_screen_notifier_2d_screen_exited():
	#if voando:
		#respawn()
#
#
#func respawn():
	#pode_processar = false
	#visible = false
	#set_physics_process(false)
	#
	#await get_tree().create_timer(10.0).timeout
	#
#
	#global_position = posicao_inicial
	#velocity = Vector2.ZERO
	#velocidade_voo = Vector2.ZERO
	#
	#pearl = false
	#voando = false
	#
	#visible = true
	#set_physics_process(true)
	#pode_processar = true
	#
	#animacao_atual = ""
	#anima.play("direita") # animação padrão
