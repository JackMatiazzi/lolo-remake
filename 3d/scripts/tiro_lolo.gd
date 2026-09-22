class_name TiroLolo
extends Area3D

@export var velocidade := 37.5
@export var alcance := 40.0

var direcao := Vector3.ZERO
var distancia_percorrida := 0.0


func configurar(nova_direcao: Vector3) -> void:
	direcao = nova_direcao.normalized()
	if direcao == Vector3.ZERO:
		queue_free()
		return

func _physics_process(delta: float) -> void:
	if direcao == Vector3.ZERO:
		return

	var passo := direcao * velocidade * delta
	global_position += passo
	distancia_percorrida += passo.length()

	if distancia_percorrida >= alcance:
		queue_free()


func _on_body_entered(corpo: Node3D) -> void:
	_atingir(corpo)


func _on_area_entered(area: Area3D) -> void:
	_atingir(area)


func _atingir(alvo: Node) -> void:
	if alvo.is_in_group("jogador"):
		return

	if alvo.has_method("tomar_tiro"):
		alvo.tomar_tiro(direcao)

	queue_free()
