extends InimigoBase

@export var cena_tiro: PackedScene = preload("res://3d/scenes/objects/tiro_gol.tscn")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var raycast: RayCast3D = $RayCast3D
@onready var marker_tiro: Marker3D = $Marker3D  # Ponto de disparo
@onready var som_tiro: AudioStreamPlayer3D = $SomTiro

var acordado: bool = false
var tiro_ativo: Area3D = null # Guarda a referência do tiro atual no jogo

func _ready() -> void:
	super._ready()
	animation_player.play("Gol_Dormindo")
	acordado = false

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if em_ovo or not acordado or is_instance_valid(tiro_ativo):
		return
	
	if raycast.is_colliding():
		var colisao = raycast.get_collider()
		if colisao and colisao.is_in_group("esmeraldas"):
			raycast.add_exception(colisao)
		if colisao and colisao.is_in_group("jogador"):
			atirar()

func acordar() -> void:
	if not acordado and not em_ovo:
		acordado = true
		animation_player.play("Gol_Acordado")

func dormir() -> void:
	if acordado:
		acordado = false
		animation_player.play("Gol_Dormindo")

func atirar() -> void:
	if cena_tiro == null or em_ovo:
		return
	
	tiro_ativo = cena_tiro.instantiate() as Area3D
	get_tree().root.add_child(tiro_ativo)
	tiro_ativo.global_transform = marker_tiro.global_transform
	som_tiro.play()
