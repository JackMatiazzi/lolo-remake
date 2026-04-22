extends Node

var disparos := 0 
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
