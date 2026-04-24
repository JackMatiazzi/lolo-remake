extends CanvasLayer

@onready var label_vidas = $VBoxContainer/LabelVidas
@onready var label_disparos = $VBoxContainer/LabelDisparos

func _ready():
	label_vidas.text = str(GameMaster.vida)
	label_disparos.text = "0"

func set_vidas(n: int):
	label_vidas.text = str(n)

func set_disparos(n: int):
	label_disparos.text = str(n)
