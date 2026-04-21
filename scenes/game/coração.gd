extends StaticBody2D

signal item_coletado

@export var magic_shot = false

func coletar():
	var shots = magic_shot
	item_coletado.emit()
	queue_free()
	return shots
