extends CharacterBody2D

@export var tile_size = 8
@export var walk_speed = 0.1
@export var tiros_disponiveis = 0: 
	set(valor):
		tiros_disponiveis = valor
		disparos_atualizados.emit(tiros_disponiveis)

@onready var anim = $AnimatedSprite2D
@onready var idle_timer = $IdleTimer
@onready var ray = $RayCast2D

signal disparos_atualizados(quantidade)
signal jogador_morreu

var ultima_direcao = Vector2.DOWN
var cena_tiro = preload("res://scenes/personagem/tiro_magico.tscn")
var morreu = false
var venceu = false
var is_moving = false
var is_idle = false


func _physics_process(_delta):
	if morreu or venceu:
		return
	
	if Input.is_action_just_pressed("ui_accept"):
		atirar()
	
	if Input.is_key_pressed(KEY_SHIFT):
		executar_morte()
		return
	
	if is_moving:
		return
		
	var input_dir = get_input_direction()
	
	if input_dir != Vector2.ZERO:
		is_idle = false
		idle_timer.stop()
		ultima_direcao = input_dir
		 
		var obstaculo = check_collision(input_dir)
		if obstaculo == null:
			move_in_grid(input_dir)
		else:
			processar_colisao(obstaculo, input_dir)
	else:
		if not is_idle:
			anim.stop();

func get_input_direction() -> Vector2:
	var input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Movimento em grade usa apenas um eixo.
	if abs(input.x) > abs(input.y):
		return Vector2(sign(input.x), 0)
	elif abs(input.y) > 0:
		return Vector2(0, sign(input.y))
		
	return Vector2.ZERO

func check_collision(direction):
	ray.position = direction * 4
	ray.target_position = direction * (tile_size - 4)
	
	ray.hit_from_inside = true
	ray.force_raycast_update()
	
	if ray.is_colliding():
		var colisor = ray.get_collider()
		if colisor.is_in_group("inimigo"):
			var distancia = global_position.distance_to(colisor.global_position)
			
			# Ignora inimigo sobreposto.
			if distancia < 2.0:
				ray.hit_from_inside = false
				ray.add_exception(colisor)
	
	ray.force_raycast_update()
	var resultado = ray.get_collider() if ray.is_colliding() else null
	
	ray.clear_exceptions()
	
	return resultado

func processar_colisao(obstaculo, input_dir):
	if obstaculo.has_method("empurrar") and alinhado(obstaculo, input_dir):
		if obstaculo.empurrar(input_dir):
			move_in_grid(input_dir)
		else:
			update_animation(input_dir)
	else:
		update_animation(input_dir)
	
func alinhado(objeto, direcao_movimento) -> bool:
	if direcao_movimento.x != 0:
		return abs(position.y - objeto.position.y) < 2.0
	
	if direcao_movimento.y != 0:
		return abs(position.x - objeto.position.x) < 2.0
		
	return false

func move_in_grid(direction):
	is_moving = true
	update_animation(direction)
	
	var target_position = position + (direction * tile_size)
	var tween = create_tween()
	tween.tween_property(self, "position", target_position, walk_speed)
	
	tween.finished.connect(func(): 
		is_moving = false
		idle_timer.start()
	)

func update_animation(direction):
	if direction == Vector2.RIGHT: anim.play("walk_right")
	elif direction == Vector2.LEFT: anim.play("walk_left")
	elif direction == Vector2.DOWN: anim.play("walk_down")
	elif direction == Vector2.UP: anim.play("walk_up")
	
func atirar():
	if tiros_disponiveis > 0 and not morreu:
		tiros_disponiveis -= 1
		is_idle = false
		update_animation(ultima_direcao)
		
		var tiro_instancia = cena_tiro.instantiate()
		tiro_instancia.position = self.position
		tiro_instancia.set_direcao(ultima_direcao)
		get_tree().current_scene.add_child(tiro_instancia)
	else:
		print("Sem munição!")
		
func receber_empurrao(direction: Vector2) -> bool:
	if is_moving or morreu:
		return false

	var obstaculo = check_collision(direction)
	
	if obstaculo == null:
		move_in_grid(direction)
		return true
	
	return false

func executar_morte():
	morreu = true
	is_moving = true
	get_tree().call_group("bau", "set_visible", false)
	get_tree().call_group("spawner", "queue_free")
	anim.play("die")

func executar_vitoria():
	venceu = true
	is_moving = true
	anim.play("victory")

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "die":
		jogador_morreu.emit()
	elif anim.animation == "victory":
		GameMaster.proxima_fase()

func _on_idle_timer_timeout():
	if not is_moving:
		is_idle = true
		anim.play("idle")

func _on_sensor_area_entered(area: Area2D) -> void:
	var alvo = null
	if area.get_parent().has_method("coletar"):
		alvo = area.get_parent()
	if alvo:
		var ganhou_tiro = alvo.coletar()
		if ganhou_tiro:
			tiros_disponiveis += 2
