extends Control

func _ready():
	await get_tree().create_timer(10.0).timeout
	get_tree().change_scene_to_file("res://scenes/game/level_1.tscn")
