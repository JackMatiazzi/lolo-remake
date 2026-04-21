extends Node2D

signal todos_coletados

var itens_restantes = 0
# 1. Variáveis para guardar as coordenadas (Vector2i guarda X e Y da grade)
var pos_bau: Vector2i = Vector2i(-1, -1)
var pos_porta: Vector2i = Vector2i(-1, -1)
# Coordenadas dos tiles no seu ATLAS (Mude para os valores REAIS do seu TileSet)
var bau_vazio = Vector2i(3, 3)
var porta_aberta = Vector2i(5, 4)

func _ready() -> void:
	mapear_objetos_estaticos()

	var lista_itens = get_tree().get_nodes_in_group("coletaveis")
	itens_restantes = lista_itens.size()
	print("Total de itens na fase: ", itens_restantes)
	
	for item in lista_itens:
		if item.has_signal("item_coletado"):
			item.item_coletado.connect(_on_item_coletado)
			
	if $Bau_aberto.has_signal("level_concluido"):
		$Bau_aberto.level_concluido.connect(_on_level_concluido)

func mapear_objetos_estaticos():
	var map = $Sala_Base
	
	# Percorre todas as células que você desenhou no editor
	for coordenada in map.get_used_cells():
		var dados = map.get_cell_tile_data(coordenada)
		
		if dados:
			# Verifica se é o baú
			if dados.get_custom_data("tipo") == "bau":
				pos_bau = coordenada
				
			# Verifica se é a porta
			if dados.get_custom_data("tipo") == "porta":
				pos_porta = coordenada

func _on_item_coletado():
	itens_restantes -= 1
	if itens_restantes <= 0:
		todos_coletados.emit()
		if pos_bau != Vector2i(-1, -1):
			$Sala_Base.set_cell(pos_bau, 1, bau_vazio)
		
func _on_level_concluido():
	if pos_porta != Vector2i(-1, -1):
		$Sala_Base.set_cell(pos_porta, 1, porta_aberta)
