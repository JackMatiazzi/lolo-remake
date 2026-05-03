extends CanvasLayer

func mudar_cena(caminho: String):
	$AnimationPlayer.play("fade_out")
	
	await $AnimationPlayer.animation_finished
	
	get_tree().change_scene_to_file(caminho)
	$AnimationPlayer.play("fade_in")
