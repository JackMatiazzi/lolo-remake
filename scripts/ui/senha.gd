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
	asteriscos.text = "****"
	_atualizar_highlight()

func _atualizar_display():
	asteriscos.text = entrada + "*".repeat(4 - entrada.length())

const SKIP_CELLS = ["", "INS", "FRD"]

func _atualizar_highlight():
	cursor.position = Vector2(col_x[col] + 3, row_y[row] + 4)

func _mover(dcol: int, drow: int):
	var c = col
	var r = row
	for _i in range(8):
		c = (c + dcol + 8) % 8
		r = (r + drow + 4) % 4
		if grid[r][c] not in SKIP_CELLS:
			col = c
			row = r
			break
	_atualizar_highlight()

func _input(_event):
	if Input.is_action_just_pressed("ui_right"):
		_mover(1, 0)
	if Input.is_action_just_pressed("ui_left"):
		_mover(-1, 0)
	if Input.is_action_just_pressed("ui_down"):
		_mover(0, 1)
	if Input.is_action_just_pressed("ui_up"):
		_mover(0, -1)
	if Input.is_action_just_pressed("ui_accept"):
		var letra = grid[row][col]
		match letra:
			"END":
				GameMaster.ir_para_senha(entrada)
			"DEL":
				if entrada.length() > 0:
					entrada = entrada.substr(0, entrada.length() - 1)
					_atualizar_display()
			"INS", "FRD", "":
				pass
			_:
				if entrada.length() < 4:
					entrada += letra
					_atualizar_display()
	if Input.is_action_just_pressed("ui_cancel"):
		if entrada.length() > 0:
			entrada = entrada.substr(0, entrada.length() - 1)
			_atualizar_display()
