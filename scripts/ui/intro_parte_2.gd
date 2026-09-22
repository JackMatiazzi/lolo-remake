extends Node2D


func _ready() -> void:
	$VideoStreamPlayer.play()


func _on_video_stream_player_finished() -> void:
	if GameMaster.inicio_3d:
		GameMaster.inicio_3d = false
		get_tree().change_scene_to_file(GameMaster.levels_3d[0])
	else:
		get_tree().change_scene_to_file("res://scenes/ui/tela_missao.tscn")
