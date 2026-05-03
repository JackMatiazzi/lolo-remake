extends Node2D


func _ready():
	while true:
		$VideoStreamPlayer.play()
		await $VideoStreamPlayer.finished

func _input(_event):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/ui/menu.tscn")
