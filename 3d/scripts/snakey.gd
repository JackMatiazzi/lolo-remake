extends CharacterBody3D

@export var tamanho_celula := 2.0
@export var velocidade_passo := 0.1
@export var duracao_ovo := 7.0
@export var grid_map_path := NodePath("../GridMap")

@onready var visual: Node3D = $Visual
@onready var ovo: MeshInstance3D = $Ovo
@onready var tempo_ovo: Timer = $TempoOvo
@onready var grid_map: GridMap = get_node_or_null(grid_map_path)
@onready var voo: AudioStreamPlayer = $voo

var jogador: Node3D
var em_ovo := false
var saindo := false
var esta_movendo := false


func _ready() -> void:
	jogador = get_tree().get_first_node_in_group("jogador") as Node3D
	tempo_ovo.wait_time = duracao_ovo
	tempo_ovo.timeout.connect(_voltar_ao_normal)


func _process(_delta: float) -> void:
	if em_ovo:
		return
	if not is_instance_valid(jogador):
		jogador = get_tree().get_first_node_in_group("jogador") as Node3D
		if jogador == null:
			return
	# parado, mas acompanha o Lolo com o olhar
	var alvo := jogador.global_position
	alvo.y = visual.global_position.y
	if visual.global_position.distance_squared_to(alvo) > 0.01:
		visual.look_at(alvo, Vector3.UP)


func tomar_tiro(direcao: Vector3) -> void:
	if saindo:
		return
	if em_ovo:
		voo.play()
		_sumir(direcao)
	else:
		em_ovo = true
		visual.hide()
		ovo.show()
		add_to_group("empurravel")
		tempo_ovo.start()


func _voltar_ao_normal() -> void:
	em_ovo = false
	remove_from_group("empurravel")
	ovo.hide()
	visual.show()


func _sumir(direcao: Vector3) -> void:
	saindo = true
	tempo_ovo.stop()
	remove_from_group("empurravel")
	collision_layer = 0
	collision_mask = 0
	var rumo := direcao.normalized() if direcao.length_squared() > 0.01 else Vector3.FORWARD
	var tween := create_tween()
	tween.tween_property(self, "global_position", global_position + rumo * 6.0 + Vector3.UP, 0.25)
	tween.finished.connect(queue_free)


func empurrar(direcao: Vector3) -> bool:
	if not em_ovo or esta_movendo:
		return false
	var movimento := direcao * tamanho_celula
	var destino := global_position + movimento
	if test_move(global_transform, movimento) or bloco_bloqueia(destino):
		return false
	mover(destino)
	return true


func mover(destino: Vector3) -> void:
	esta_movendo = true
	var tween := create_tween()
	tween.tween_property(self, "global_position", destino, velocidade_passo)
	tween.finished.connect(func(): esta_movendo = false)


func bloco_bloqueia(destino: Vector3) -> bool:
	if grid_map == null or grid_map.mesh_library == null:
		return false
	var celula := grid_map.local_to_map(grid_map.to_local(destino))
	celula.y = 0
	var id := grid_map.get_cell_item(celula)
	if id == GridMap.INVALID_CELL_ITEM:
		return false
	return grid_map.mesh_library.get_item_name(id) in ["Parede", "Agua"]
