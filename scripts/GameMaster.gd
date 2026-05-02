extends Node

var levels = [
	"res://scenes/levels/level_1.tscn",
	"res://scenes/levels/level_2.tscn",
	"res://scenes/levels/level_3.tscn",
	"res://scenes/levels/level_4.tscn",
	"res://scenes/levels/level_5.tscn"
]
var level_atual_index = 0

var vida:= 5

func _ao_morrer():
	if vida <= 0:
		return
	vida -= 1
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.set_vidas(vida)
	if vida <= 0:
		get_tree().quit()
	else:
		get_tree().reload_current_scene()

func proxima_fase():
	level_atual_index += 1
	if level_atual_index < levels.size():
		get_tree().change_scene_to_file(levels[level_atual_index])
	else:
		print("Parabéns! Você completou todas as fases.")
		# Aqui você poderia carregar uma tela de créditos ou menu principalfunc proxima_fase():
	level_atual_index += 1
		
