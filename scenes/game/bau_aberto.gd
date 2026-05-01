extends StaticBody2D

signal level_concluido

@onready var anim = $AnimatedSprite2D

func _ready() -> void:
	visible = false
	if get_parent().has_signal("todos_coletados"):
		get_parent().todos_coletados.connect(_on_level_todos_coletados)

func coletar():
	if visible:
		if anim.frame == 0:
			anim.frame = 1
			level_concluido.emit()
			
	return false

func _on_level_todos_coletados():
	visible = true
	set_collision_layer_value(2, false)
