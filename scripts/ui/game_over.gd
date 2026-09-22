extends Control

func _ready():
	$Panel/senha_label.text = "" if GameMaster.game_over_em_3d else GameMaster.senha_atual()

func _input(_event):
	if Input.is_action_just_pressed("ui_accept"):
		Fade.mudar_cena("res://scenes/ui/intro_parte1.tscn")
