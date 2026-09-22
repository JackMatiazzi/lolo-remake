extends Control

const CURSOR_Y = [40, 56, 72]
const OPCAO_2D = 0
const OPCAO_3D = 1
const OPCAO_SENHA = 2

@onready var cursor = $Fundo/Cursor
@onready var label_senha = $Fundo/senha

var opcao = OPCAO_2D

func _ready():
	cursor.play("default")
	if GameMaster.veio_de_game_over:
		label_senha.text = "CONTINUAR"
		opcao = OPCAO_SENHA
		cursor.position.y = CURSOR_Y[OPCAO_SENHA]

func _input(_event):
	if Input.is_action_just_pressed("ui_up"):
		opcao = (opcao - 1 + CURSOR_Y.size()) % CURSOR_Y.size()
		cursor.position.y = CURSOR_Y[opcao]
	if Input.is_action_just_pressed("ui_down"):
		opcao = (opcao + 1) % CURSOR_Y.size()
		cursor.position.y = CURSOR_Y[opcao]
	if Input.is_action_just_pressed("ui_accept"):
		if opcao == OPCAO_2D:
			GameMaster.resetar()
			Fade.mudar_cena("res://scenes/ui/intro_parte2.tscn")
		elif opcao == OPCAO_3D:
			GameMaster.resetar()
			GameMaster.inicio_3d = true
			Fade.mudar_cena("res://scenes/ui/intro_parte2.tscn")
		elif opcao == OPCAO_SENHA:
			if GameMaster.veio_de_game_over:
				GameMaster.vida = 5
				if GameMaster.game_over_em_3d:
					Fade.mudar_cena(GameMaster.levels_3d[GameMaster.level_atual_index])
				else:
					Fade.mudar_cena(GameMaster.levels[GameMaster.level_atual_index])
			else:
				Fade.mudar_cena("res://scenes/ui/senha.tscn")
