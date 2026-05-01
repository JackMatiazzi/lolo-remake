extends Node2D

@export var tempo_respawn: float = 8.0
@export var tempo_pre_visualizacao: float = 2.0 # Quanto tempo o alerta fica na tela
@export var sprite_alerta: Texture2D # Arraste um sprite de fumaça/brilho aqui

var registro_inimigos = {}
var level_ativo = true

func _ready():
	# Conexão com o baú
	var bau = get_tree().get_first_node_in_group("bau")
	if bau:
		# Quando o level for concluído, mudamos o estado e deletamos
		bau.level_concluido.connect(_ao_concluir_level)
	
	await get_tree().process_frame
	for inimigo in get_children():
		if inimigo is CharacterBody2D:
			registrar_inimigo(inimigo, inimigo.global_position, inimigo.scene_file_path)

func _ao_concluir_level():
	level_ativo = false # Trava o spawn imediatamente
	queue_free()        # Remove o spawner e todos os inimigos filhos

func registrar_inimigo(inimigo: CharacterBody2D, pos: Vector2, caminho: String):
	var id = inimigo.get_instance_id()
	registro_inimigos[id] = { "posicao": pos, "arquivo": caminho }
	if not inimigo.tree_exited.is_connected(_ao_inimigo_sair):
		inimigo.tree_exited.connect(_ao_inimigo_sair.bind(id))

func _ao_inimigo_sair(id_antigo: int):
	# Se o spawner não estiver na árvore (ex: fase reiniciando), para tudo.
	if not is_inside_tree(): return
	
	if not level_ativo: return
	
	if not registro_inimigos.has(id_antigo): return
	
	var dados = registro_inimigos[id_antigo]
	
	# 1. Espera o tempo de "vazio" (Tempo total menos o tempo do alerta)
	var tempo_espera_real = max(0.1, tempo_respawn - tempo_pre_visualizacao)
	await get_tree().create_timer(tempo_espera_real).timeout
	
	# 2. Mostra o alerta (Fumaça/Brilho)
	mostrar_alerta(dados["posicao"])
	
	# 3. Espera o tempo do alerta terminar
	await get_tree().create_timer(tempo_pre_visualizacao).timeout
	
	# 4. Spawna o inimigo real
	var cena_recarregada = load(dados["arquivo"])
	var novo_inimigo = cena_recarregada.instantiate()
	novo_inimigo.global_position = dados["posicao"]
	add_child(novo_inimigo)
	
	registrar_inimigo(novo_inimigo, dados["posicao"], dados["arquivo"])
	registro_inimigos.erase(id_antigo)

func mostrar_alerta(pos: Vector2):
	var alerta = Sprite2D.new()
	alerta.texture = sprite_alerta
	alerta.global_position = pos
	add_child(alerta)
	
	# Cria um efeito simples de piscar ou crescer
	var tween = create_tween()
	tween.tween_property(alerta, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(alerta, "scale", Vector2(1.0, 1.0), 0.2)
	tween.set_loops(int(tempo_pre_visualizacao / 0.4))
	
	# Deleta o alerta quando o tempo acabar
	await get_tree().create_timer(tempo_pre_visualizacao).timeout
	alerta.queue_free()
