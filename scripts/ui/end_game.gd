extends Control

func _ready():
	await get_tree().create_timer(10.0).timeout
	GameMaster.resetar()
	Fade.mudar_cena("res://scenes/ui/intro_parte1.tscn")
