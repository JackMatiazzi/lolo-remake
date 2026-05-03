extends Control

@onready var cursor = $Fundo/Cursor

var opcao = 0

func _ready():
	cursor.play("default")

func _input(event):
	if Input.is_action_just_pressed("ui_up"):
		opcao = 0
		cursor.position.y = 40
	if Input.is_action_just_pressed("ui_down"):
		opcao = 1
		cursor.position.y = 56
	if Input.is_action_just_pressed("ui_accept"):
		if opcao == 0:
			Fade.mudar_cena("res://scenes/ui/intro_parte2.tscn")
