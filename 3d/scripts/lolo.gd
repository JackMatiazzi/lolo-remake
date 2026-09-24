extends CharacterBody3D

@export var tamanho_celula := 2.0
@export var velocidade_passo := 0.1
@export var velocidade_giro := 0.15
@export_range(1.0, 4.0, 0.1) var ritmo_caminhada := 2.5
@export_range(1.0, 4.0, 0.1) var ritmo_empurrao := 2.0
@export var grid_map_path := NodePath("../GridMap")
@export var altura_saida_tiro := 1.0
@export var distancia_saida_tiro := 1.6

const BLOCOS_IMPASSAVEIS := ["Parede", "Agua"]
const GRUPO_EMPURRAVEL := "empurravel"
const CENA_TIRO := preload("res://3d/scenes/objects/tiro_lolo.tscn")

@onready var anim: AnimationPlayer = $Modelo/AnimationPlayer
@onready var idle_timer: Timer = $IdleTimer
@onready var camera_primeira_pessoa: Camera3D = $CameraPrimeiraPessoa
@onready var grid_map: GridMap = get_node_or_null(grid_map_path)
@onready var tiro_lolo: AudioStreamPlayer = $tiro_lolo
@onready var pegar_coracao: AudioStreamPlayer = $pegar_coracao
@onready var morte: AudioStreamPlayer = $morte

var esta_movendo := false
var em_primeira_pessoa := false
var camera_anterior: Camera3D = null
var morreu := false
var venceu := false
var tiros_disponiveis := 0
var ultima_direcao := Vector3(0, 0, -1)

func _ready() -> void:
	anim.get_animation("walk").loop_mode = Animation.LOOP_LINEAR
	anim.get_animation("push").loop_mode = Animation.LOOP_LINEAR
	anim.get_animation("idle").loop_mode = Animation.LOOP_LINEAR
	anim.play("idle")
	anim.seek(0.0, true)
	anim.pause()
	idle_timer.timeout.connect(_ao_timeout_idle)
	idle_timer.start()

func _unhandled_input(event: InputEvent) -> void:
	if morreu or venceu:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		alternar_primeira_pessoa()
	elif event.is_action_pressed("ui_accept"):
		disparar()

func alternar_primeira_pessoa() -> void:
	em_primeira_pessoa = not em_primeira_pessoa
	if em_primeira_pessoa:
		camera_anterior = get_viewport().get_camera_3d()
		camera_primeira_pessoa.current = true
	else:
		camera_primeira_pessoa.current = false
		if camera_anterior:
			camera_anterior.current = true

func _physics_process(_delta: float) -> void:
	if morreu or venceu:
		return

	if Input.is_key_pressed(KEY_SHIFT):
		executar_morte()
		return

	# espera o passo ou o giro atual terminar
	if esta_movendo:
		return

	var frente := -global_transform.basis.z.round()

	if Input.is_action_pressed("ui_up"):
		idle_timer.stop()
		mover_na_grade(frente)
	elif Input.is_action_just_pressed("ui_down"):
		idle_timer.stop()
		virar_para(-frente)
	elif Input.is_action_just_pressed("ui_left"):
		idle_timer.stop()
		virar_para(Vector3(frente.z, 0, -frente.x))
	elif Input.is_action_just_pressed("ui_right"):
		idle_timer.stop()
		virar_para(Vector3(-frente.z, 0, frente.x))
	elif not _segurando_direcao():
		if anim.current_animation == "walk" or anim.current_animation == "push":
			anim.pause()
		if idle_timer.is_stopped():
			idle_timer.start()

func _segurando_direcao() -> bool:
	return Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down") \
		or Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")

func _ao_timeout_idle() -> void:
	if not esta_movendo and not morreu and not venceu and not _segurando_direcao():
		anim.play("idle")

func virar_para(nova_direcao: Vector3) -> void:
	ultima_direcao = nova_direcao
	esta_movendo = true
	_animar_movimento(false)
	var giro := create_tween()
	var rotacao_alvo := Basis.looking_at(nova_direcao, Vector3.UP).get_rotation_quaternion()
	giro.tween_property(self, "quaternion", rotacao_alvo, velocidade_giro)
	giro.finished.connect(func():
		esta_movendo = false
		if not morreu and not venceu:
			idle_timer.start()
	)

func executar_vitoria() -> void:
	if morreu or venceu:
		return
	venceu = true
	esta_movendo = true
	if em_primeira_pessoa:
		alternar_primeira_pessoa()

	# vira para a camera antes da vitoria
	var camera_jogo := get_viewport().get_camera_3d()
	if camera_jogo:
		var para_camera := camera_jogo.global_position - global_position
		para_camera.y = 0.0
		if para_camera.length_squared() > 0.01:
			anim.play("idle")
			var rotacao_alvo := Basis.looking_at(para_camera.normalized(), Vector3.UP).get_rotation_quaternion()
			var giro := create_tween()
			giro.tween_property(self, "quaternion", rotacao_alvo, velocidade_giro)
			await giro.finished

	anim.play("victory")
	await anim.animation_finished
	GameMaster.proxima_fase_3d()

func executar_morte() -> void:
	if morreu or venceu:
		return
	morreu = true
	esta_movendo = true
	anim.play("die")
	morte.play()
	await anim.animation_finished
	GameMaster._ao_morrer_3d()

func ganhar_tiros(quantidade: int) -> void:
	tiros_disponiveis += quantidade
	pegar_coracao.play()
	atualizar_hud_tiros()

func atualizar_hud_tiros() -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud:
		hud.set_disparos(tiros_disponiveis)

func disparar() -> void:
	if morreu or venceu or tiros_disponiveis <= 0:
		return

	var tiro := CENA_TIRO.instantiate() as TiroLolo
	get_tree().current_scene.add_child(tiro)
	# o tiro sai na frente do corpo
	tiro_lolo.play()
	tiro.global_position = global_position \
		+ Vector3.UP * altura_saida_tiro \
		+ ultima_direcao * distancia_saida_tiro
	tiro.configurar(ultima_direcao)

	tiros_disponiveis -= 1
	atualizar_hud_tiros()

func bloco_bloqueia(destino: Vector3) -> bool:
	if grid_map == null or grid_map.mesh_library == null:
		return false
	# agua e parede sao checadas pelo bloco do mapa
	var celula := grid_map.local_to_map(grid_map.to_local(destino))
	celula.y = 0 # olha o piso, nao a altura do lolo
	var item_id := grid_map.get_cell_item(celula)
	if item_id == GridMap.INVALID_CELL_ITEM:
		return false
	var nome := grid_map.mesh_library.get_item_name(item_id)
	return nome in BLOCOS_IMPASSAVEIS

func mover_na_grade(direcao: Vector3) -> void:
	ultima_direcao = direcao
	quaternion = Basis.looking_at(direcao, Vector3.UP).get_rotation_quaternion()

	var movimento := direcao * tamanho_celula
	var destino := global_position + movimento
	if bloco_bloqueia(destino):
		_animar_movimento(false)
		return

	var empurrando := false
	var colisao := KinematicCollision3D.new()
	# pedra e arbusto barram so quem esta no grupo empurravel pode ser empurrado
	if test_move(global_transform, movimento, colisao):
		var colisor := colisao.get_collider()
		if not colisor is Node3D or not colisor.is_in_group(GRUPO_EMPURRAVEL) \
			or not alinhado(colisor, direcao) or not colisor.empurrar(direcao):
			_animar_movimento(false)
			return
		empurrando = true

	esta_movendo = true
	_animar_movimento(empurrando)
	var tween := create_tween()
	tween.tween_property(self, "global_position", destino, velocidade_passo)
	tween.finished.connect(func():
		esta_movendo = false
		if not morreu and not venceu:
			idle_timer.start()
	)

func alinhado(objeto: Node3D, direcao: Vector3) -> bool:
	if direcao.x != 0:
		return abs(global_position.z - objeto.global_position.z) < 0.5
	return abs(global_position.x - objeto.global_position.x) < 0.5

func _animar_movimento(empurrando: bool) -> void:
	var nome := "push" if empurrando else "walk"
	if anim.current_animation != nome or not anim.is_playing():
		var ritmo := ritmo_empurrao if empurrando else ritmo_caminhada
		anim.play(nome, -1.0, ritmo)
