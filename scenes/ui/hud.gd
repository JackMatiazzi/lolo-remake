extends CanvasLayer

@onready var label_vidas = $VBoxContainer/LabelVidas
@onready var label_disparos = $VBoxContainer/LabelDisparos

func _ready():
	add_to_group("hud")
	label_vidas.text = str(GameMaster.vida)
	label_disparos.text = str(GameMaster.disparos)

func set_vidas(n: int):
	label_vidas.text = str(n)

func set_disparos(n: int):
	label_disparos.text = str(n)
