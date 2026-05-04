extends Control

@onready var cursor = $TextureRect/Cursor
@onready var asteriscos = $Asteriscos

var col = 0
var row = 0
var entrada = ""

var grid = [
	["A","B","C","D","E","F","G","H"],
	["I","J","K","L","M","N","O","P"],
	["Q","R","S","T","U","V","W","X"],
	["Y","Z","","DEL","INS","FRD","END",""]
]

var col_x = [49, 65, 81, 97, 113, 129, 145, 161]
var row_y = [33, 49, 65, 81]

func _ready():
	_atualizar_highlight()

func _atualizar_highlight():
	cursor.position = Vector2(col_x[col], row_y[row])

func _input(_event):
	if Input.is_action_just_pressed("ui_right"):
		col = (col + 1) % 8
		_atualizar_highlight()
	if Input.is_action_just_pressed("ui_left"):
		col = (col - 1 + 8) % 8
		_atualizar_highlight()
	if Input.is_action_just_pressed("ui_down"):
		row = (row + 1) % 4
		_atualizar_highlight()
	if Input.is_action_just_pressed("ui_up"):
		row = (row - 1 + 4) % 4
		_atualizar_highlight()
	if Input.is_action_just_pressed("ui_accept"):
		var letra = grid[row][col]
		match letra:
			"END":
				GameMaster.ir_para_senha(entrada)
			"DEL":
				if entrada.length() > 0:
					entrada = entrada.substr(0, entrada.length() - 1)
					asteriscos.text = "*".repeat(entrada.length())
			"INS", "FRD", "":
				pass
			_:
				if entrada.length() < 4:
					entrada += letra
					asteriscos.text = "*".repeat(entrada.length())
	if Input.is_action_just_pressed("ui_cancel"):
		if entrada.length() > 0:
			entrada = entrada.substr(0, entrada.length() - 1)
			asteriscos.text = "*".repeat(entrada.length())
