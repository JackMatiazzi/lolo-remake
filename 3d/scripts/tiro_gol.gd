extends Area3D

@export var velocidade: float = 15.0
var id_arbusto: int = 4

func _physics_process(delta: float) -> void:
	# Move para a frente (-Z local)
	global_position -= global_transform.basis.z * velocidade * delta

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("jogador"):
		if body.has_method("executar_morte"):
			body.executar_morte()
			get_tree().call_group("inimigo", "dormir")
		queue_free()
		return
	
	if body is GridMap:
		var gridmap: GridMap = body
		# Pega a lista de TODAS as células do mapa que são ArbustoVerde (ID 4)
		var celulas_arbusto = gridmap.get_used_cells_by_item(id_arbusto)
		# Converte a posição atual do tiro para a coordenada da célula no GridMap
		var celula_atual = gridmap.local_to_map(gridmap.to_local(global_position + Vector3(0,0,1)))
		# Se a posição do tiro estiver dentro da lista de células do arbusto, IGNORA!
		if celulas_arbusto.has(celula_atual):
			return # O tiro atravessa e continua voando!
		
	queue_free()
