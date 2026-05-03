extends Control

@onready var cursor = $Fundo/Cursor
@onready var label_senha = $Fundo/senha

var opcao = 0

func _ready():
	cursor.play("default")
	if GameMaster.veio_de_game_over:
		label_senha.text = "CONTINUAR"

func _input(_event):
	if Input.is_action_just_pressed("ui_up"):
		opcao = 0
		cursor.position.y = 40
	if Input.is_action_just_pressed("ui_down"):
		opcao = 1
		cursor.position.y = 56
	if Input.is_action_just_pressed("ui_accept"):
		if opcao == 0:
			GameMaster.resetar()
			Fade.mudar_cena("res://scenes/ui/intro_parte2.tscn")
		elif opcao == 1:
			if GameMaster.veio_de_game_over:
				GameMaster.vida = 5
				Fade.mudar_cena(GameMaster.levels[GameMaster.level_atual_index])
