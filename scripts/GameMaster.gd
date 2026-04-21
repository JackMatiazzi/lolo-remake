extends Node


var vida:= 5

func _ao_morrer():
	if vida <= 0:
		return             # já está em game over, ignora
	vida -= 1
	if vida <= 0:
		get_tree().quit()   # fecha o jogo
	else:
		get_tree().reload_current_scene()
