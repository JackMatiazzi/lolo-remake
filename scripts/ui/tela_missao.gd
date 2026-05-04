extends Control

func _ready():
	await get_tree().create_timer(10.0).timeout
	Fade.mudar_cena("res://scenes/levels/level_1.tscn")
