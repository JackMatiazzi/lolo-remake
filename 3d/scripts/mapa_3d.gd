extends Node3D

var coracoes_restantes := 0


func _ready() -> void:
	configurar_objetivos()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Fade.mudar_cena("res://scenes/ui/menu.tscn")


func configurar_objetivos() -> void:
	var coracoes := _nos_do_mapa("coracoes")
	coracoes_restantes = coracoes.size()
	for coracao in coracoes:
		coracao.coletado.connect(_ao_coletar_coracao)

	for bau in _nos_do_mapa("baus"):
		bau.joia_coletada.connect(_ao_coletar_joia)

	atualizar_hud()

	if coracoes_restantes == 0:
		abrir_baus()


func atualizar_hud() -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.set_coracoes(coracoes_restantes)


func _nos_do_mapa(grupo: StringName) -> Array[Node]:
	var resultado: Array[Node] = []
	for no in get_tree().get_nodes_in_group(grupo):
		if is_ancestor_of(no):
			resultado.append(no)
	return resultado


func _ao_coletar_coracao(da_tiro_magico: bool = false) -> void:
	coracoes_restantes = maxi(coracoes_restantes - 1, 0)
	atualizar_hud()

	if da_tiro_magico:
		var jogador := get_tree().get_first_node_in_group("jogador")
		if jogador:
			jogador.ganhar_tiros(2)

	if coracoes_restantes == 0:
		abrir_baus()
		get_tree().call_group("inimigo", "acordar")


func abrir_baus() -> void:
	for bau in _nos_do_mapa("baus"):
		bau.abrir()

func _ao_coletar_joia() -> void:
	get_tree().call_group("inimigo", "queue_free")
	$Musica.stop()
	for porta in _nos_do_mapa("portas"):
		porta.abrir()
