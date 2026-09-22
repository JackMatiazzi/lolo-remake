extends CharacterBody3D

@export var tamanho_celula := 2.0
@export var velocidade_passo := 0.1
@export var grid_map_path := NodePath("../GridMap")

const BLOCOS_IMPASSAVEIS := ["Parede", "Agua"]

@onready var grid_map: GridMap = get_node_or_null(grid_map_path)

var esta_movendo := false


func empurrar(direcao: Vector3) -> bool:
	if esta_movendo:
		return false

	var movimento := direcao * tamanho_celula
	var destino := global_position + movimento

	if test_move(global_transform, movimento):
		return false
	if bloco_bloqueia(destino):
		return false

	mover(movimento)
	return true


func bloco_bloqueia(destino: Vector3) -> bool:
	if grid_map == null or grid_map.mesh_library == null:
		return false
	var celula := grid_map.local_to_map(grid_map.to_local(destino))
	celula.y = 0 # a esmeralda sempre fica mo andar 0 da grade
	var item_id := grid_map.get_cell_item(celula)
	if item_id == GridMap.INVALID_CELL_ITEM:
		return false
	var nome := grid_map.mesh_library.get_item_name(item_id)
	return nome in BLOCOS_IMPASSAVEIS


func mover(movimento: Vector3) -> void:
	esta_movendo = true
	var destino := global_position + movimento
	var tween := create_tween()
	tween.tween_property(self, "global_position", destino, velocidade_passo)
	tween.finished.connect(func():
		esta_movendo = false
	)
