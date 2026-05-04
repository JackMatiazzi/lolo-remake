extends CanvasLayer

func _ready():
	get_tree().paused = true

func _input(_event):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().paused = false
		queue_free()
