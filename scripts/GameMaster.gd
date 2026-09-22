extends Node

var levels = [
	"res://scenes/levels/level_1.tscn",
	"res://scenes/levels/level_2.tscn",
	"res://scenes/levels/level_3.tscn",
	"res://scenes/levels/level_4.tscn",
	"res://scenes/levels/level_5.tscn"
]

var levels_3d = [
	"res://3d/scenes/levels/mapa_1_1.tscn",
	"res://3d/scenes/levels/mapa_1_2.tscn",
]


var senhas = {
	"BBBV": 0,
	"BCBT": 1,
	"BDBR": 2,
	"BGBQ": 3,
	"BHBP": 4
}

var level_atual_index = 0
var vida := 5
var veio_de_game_over = false
var game_over_em_3d = false
var inicio_3d = false

func _ao_morrer():
	if vida <= 0:
		return
	vida -= 1
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.set_vidas(vida)
	var idx = levels.find(get_tree().current_scene.scene_file_path)
	if idx >= 0:
		level_atual_index = idx
	if vida <= 0:
		veio_de_game_over = true
		game_over_em_3d = false
		Fade.mudar_cena("res://scenes/ui/game_over.tscn")
	else:
		Fade.mudar_cena(levels[level_atual_index])

func proxima_fase():
	level_atual_index += 1
	if level_atual_index < levels.size():
		Fade.mudar_cena(levels[level_atual_index])
	else:
		Fade.mudar_cena("res://scenes/ui/end_game.tscn")

func _ao_morrer_3d():
	if vida <= 0:
		return
	vida -= 1
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.set_vidas(vida)
	var idx = levels_3d.find(get_tree().current_scene.scene_file_path)
	if idx >= 0:
		level_atual_index = idx
	if vida <= 0:
		veio_de_game_over = true
		game_over_em_3d = true
		Fade.mudar_cena("res://scenes/ui/game_over.tscn")
	else:
		Fade.mudar_cena(levels_3d[level_atual_index])

func proxima_fase_3d():
	level_atual_index += 1
	if level_atual_index < levels_3d.size():
		Fade.mudar_cena(levels_3d[level_atual_index])
	else:
		Fade.mudar_cena("res://scenes/ui/end_game.tscn")

func ir_para_senha(senha: String):
	if senhas.has(senha):
		level_atual_index = senhas[senha]
		vida = 5
		veio_de_game_over = false
		Fade.mudar_cena(levels[level_atual_index])
	else:
		Fade.mudar_cena("res://scenes/ui/menu.tscn")

func resetar():
	level_atual_index = 0
	vida = 5
	veio_de_game_over = false
	game_over_em_3d = false
	inicio_3d = false

func senha_atual() -> String:
	for s in senhas:
		if senhas[s] == level_atual_index:
			return s
	return ""
