extends StaticBody3D

@onready var animacao: AnimationPlayer = $Modelo/AnimationPlayer
@onready var colisao: CollisionShape3D = $CollisionShape3D
@onready var area_vitoria: Area3D = $AreaVitoria

var aberta := false


func _ready() -> void:
	area_vitoria.body_entered.connect(_ao_entrar_na_area)


func abrir() -> void:
	if aberta:
		return

	aberta = true
	animacao.play("abrir")
	await animacao.animation_finished
	colisao.set_deferred("disabled", true)


func _ao_entrar_na_area(corpo: Node3D) -> void:
	if not aberta or not corpo.is_in_group("jogador"):
		return
	corpo.executar_vitoria()
