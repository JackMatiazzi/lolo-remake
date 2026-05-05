extends CanvasLayer

@onready var anim = $AnimationPlayer

func mudar_cena(caminho: String):
	anim.play("fade_out")
	await anim.animation_finished
	get_tree().change_scene_to_file(caminho)
	await get_tree().process_frame
	anim.play("fade_in")
