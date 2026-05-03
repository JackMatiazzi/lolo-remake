extends Control

func _ready():
	await get_tree().create_timer(10.0).timeout
	Fade.mudar_cena("res://scenes/game/level_1.tscn")
