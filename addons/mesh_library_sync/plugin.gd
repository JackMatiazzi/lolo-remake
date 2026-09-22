@tool
extends EditorPlugin

# cena com os blocos que entram na biblioteca
const cena_origem := "res://3d/scenes/blocks/blocos_source.tscn"

# arquivo que o GridMap usa
const arquivo_biblioteca := "res://3d/scenes/blocks/blocos.tres"

# pastas que o plugin acompanha
const pastas := ["res://3d/scenes/blocks/", "res://3d/scenes/objects/"]
const pasta_modelos := "res://assets/models/props/"
const menu_atualizar := "Atualizar blocos 3D"

# ids guardados nas celulas do GridMap
const ids_blocos := {
	"Parede": 0, 
	"Agua": 2, 
	"TijoloEscuro": 3, 
	"ArbustoVerde": 4, 
	"PedraAmarela": 5, 
	"Ponte": 7, 
}

var ultima_alteracao := 0


func _enter_tree() -> void:
	# começa a observar as cenas
	var arquivos := get_editor_interface().get_resource_filesystem()
	arquivos.filesystem_changed.connect(_verificar_alteracoes)
	arquivos.resources_reimported.connect(_ao_reimportar)
	add_tool_menu_item(menu_atualizar, _atualizar_biblioteca)
	ultima_alteracao = _obter_ultima_alteracao()


func _exit_tree() -> void:
	# desliga o sinal junto com o plugin
	var arquivos := get_editor_interface().get_resource_filesystem()
	if arquivos.filesystem_changed.is_connected(_verificar_alteracoes):
		arquivos.filesystem_changed.disconnect(_verificar_alteracoes)
	if arquivos.resources_reimported.is_connected(_ao_reimportar):
		arquivos.resources_reimported.disconnect(_ao_reimportar)
	remove_tool_menu_item(menu_atualizar)


func _verificar_alteracoes() -> void:
	# so atualiza se algum arquivo mudou
	var alteracao := _obter_ultima_alteracao()
	if alteracao <= ultima_alteracao:
		return
	ultima_alteracao = alteracao
	_atualizar_biblioteca()


func _ao_reimportar(recursos: PackedStringArray) -> void:
	for recurso in recursos:
		if recurso.begins_with(pasta_modelos) and recurso.ends_with(".glb"):
			call_deferred("_atualizar_biblioteca")
			return


func _obter_ultima_alteracao() -> int:
	# procura a cena alterada mais recentemente
	var ultima := 0
	for pasta in pastas:
		for arquivo in DirAccess.get_files_at(pasta):
			if arquivo.ends_with(".tscn"):
				var caminho: String = pasta.path_join(arquivo)
				ultima = maxi(ultima, FileAccess.get_modified_time(caminho))
	return ultima


func _atualizar_biblioteca() -> void:
	# abre a cena que junta todos os blocos
	var cena := ResourceLoader.load(
		cena_origem, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE_DEEP
	) as PackedScene
	if cena == null:
		push_error("nao carregou: " + cena_origem)
		return

	var origem := cena.instantiate()
	var biblioteca := load(arquivo_biblioteca) as MeshLibrary
	if biblioteca == null:
		biblioteca = MeshLibrary.new()
	else:
		biblioteca.clear()
	var proximo_id := _proximo_id()

	for item in origem.get_children():
		# pega a malha do bloco
		var malhas := item.find_children("*", "MeshInstance3D", true, false)
		if malhas.is_empty():
			continue

		var malha := malhas[0] as MeshInstance3D
		if malha.mesh == null:
			continue

		# mantem o mesmo numero no GridMap
		var nome_item := str(item.name)
		var id: int = ids_blocos.get(nome_item, proximo_id)
		if not ids_blocos.has(nome_item):
			proximo_id += 1

		# salva a malha
		biblioteca.create_item(id)
		biblioteca.set_item_name(id, nome_item)
		biblioteca.set_item_mesh(id, malha.mesh)
		biblioteca.set_item_mesh_transform(id, _transformacao_relativa(malha, item))

		# salva as colisoes
		var formas: Array = []
		for colisao in item.find_children("*", "CollisionShape3D", true, false):
			if colisao.shape != null:
				formas.append(colisao.shape)
				formas.append(_transformacao_relativa(colisao, item))
		if not formas.is_empty():
			biblioteca.set_item_shapes(id, formas)

	origem.free()
	var erro := ResourceSaver.save(biblioteca, arquivo_biblioteca)
	if erro != OK:
		push_error("erro ao salvar: " + arquivo_biblioteca)
	else:
		biblioteca.emit_changed()


func _proximo_id() -> int:
	# numero usado por um bloco novo
	var proximo := 0
	for id in ids_blocos.values():
		proximo = maxi(proximo, int(id) + 1)
	return proximo


func _transformacao_relativa(no: Node3D, raiz: Node3D) -> Transform3D:
	# posicao da malha dentro do bloco
	var resultado := Transform3D.IDENTITY
	var atual: Node = no
	while atual != null and atual != raiz:
		if atual is Node3D:
			resultado = (atual as Node3D).transform * resultado
		atual = atual.get_parent()
	return resultado
