extends Node

var levels = [
	"res://scenes/levels/level_1.tscn",
	"res://scenes/levels/level_2.tscn",
	"res://scenes/levels/level_3.tscn",
	"res://scenes/levels/level_4.tscn",
	"res://scenes/levels/level_5.tscn"
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

func _ao_morrer():
	if vida <= 0:
		return
	vida -= 1
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.set_vidas(vida)
	if vida <= 0:
		veio_de_game_over = true
		Fade.mudar_cena("res://scenes/ui/game_over.tscn")
	else:
		Fade.mudar_cena(levels[level_atual_index])

func proxima_fase():
	level_atual_index += 1
	if level_atual_index < levels.size():
		Fade.mudar_cena(levels[level_atual_index])
	else:
		Fade.mudar_cena("res://scenes/ui/menu.tscn")

func ir_para_senha(senha: String):
	if senhas.has(senha):
		senha = senhas[level_atual_index]
		vida = 5
		veio_de_game_over = false
		Fade.mudar_cena(levels[level_atual_index])
	else:
		Fade.mudar_cena("res://scenes/ui/menu.tscn")

func resetar():
	level_atual_index = 0
	vida = 5
	veio_de_game_over = false

func senha_atual() -> String:
	for s in senhas:
		if senhas[s] == level_atual_index:
			return s
	return ""
