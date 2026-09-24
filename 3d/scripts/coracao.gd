extends Area3D

signal coletado(da_tiro_magico: bool)

@export var da_tiro_magico := false

@onready var animacao: AnimationPlayer = $Modelo/AnimationPlayer
@onready var colisao: CollisionShape3D = $CollisionShape3D
@onready var som_coletar: AudioStreamPlayer3D = $AudioStreamPlayer3D

var foi_coletado := false

func _ready() -> void:
	body_entered.connect(_ao_entrar)
	var pulsar := animacao.get_animation("pulsar")
	if pulsar:
		pulsar.loop_mode = Animation.LOOP_LINEAR
		animacao.play("pulsar")


func _ao_entrar(corpo: Node3D) -> void:
	if foi_coletado or not corpo.is_in_group("jogador"):
		return

	foi_coletado = true
	$Modelo.hide()
	set_deferred("monitoring", false)
	colisao.set_deferred("disabled", true)
	coletado.emit(da_tiro_magico)
	som_coletar.play()
	await som_coletar.finished
	queue_free()
