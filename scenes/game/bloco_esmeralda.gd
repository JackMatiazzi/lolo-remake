extends CharacterBody2D

@export var tile_size = 8
@export var walk_speed = 0.1

@onready var ray = $RayCast2D

var is_moving = false

func empurrar(direction: Vector2) -> bool:
	if is_moving:
		return false
		
	# Aponta o laser para frente
	ray.target_position = direction * tile_size
	ray.force_raycast_update()
	
	# Se o laser bater em algo (Parede OU outro Bloco), ele não move
	if ray.is_colliding():
		return false
	
	# Se o caminho estiver totalmente livre, move
	mover_bloco(direction)
	return true
	
func mover_bloco(direction):
	is_moving = true
	var target_position = position + (direction * tile_size)
	var tween = create_tween()
	tween.tween_property(self, "position", target_position, walk_speed)
	tween.finished.connect(func(): is_moving = false)
	
