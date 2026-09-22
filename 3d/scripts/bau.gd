extends StaticBody3D

signal joia_coletada

@export_range(1.0, 1.6, 0.05) var escala_joia := 1.3

@onready var animacao: AnimationPlayer = $Modelo/AnimationPlayer
@onready var area_coleta: Area3D = $AreaColeta
@onready var colisao: CollisionShape3D = $CollisionShape3D
@onready var malha_base: MeshInstance3D = $Modelo/Bau_Joia/Malha_Base_Bau

var aberto := false
var joia_foi_coletada := false
var joia_visual: MeshInstance3D


func _ready() -> void:
	_preparar_joia()
	area_coleta.monitoring = false
	area_coleta.body_entered.connect(_ao_entrar_na_area)


func abrir() -> void:
	if aberto:
		return

	aberto = true
	animacao.play("abrir")
	area_coleta.set_deferred("monitoring", true)
	colisao.set_deferred("disabled", true)


func _ao_entrar_na_area(corpo: Node3D) -> void:
	if not aberto or joia_foi_coletada or not corpo.is_in_group("jogador"):
		return

	joia_foi_coletada = true
	area_coleta.set_deferred("monitoring", false)
	_ocultar_joia()
	joia_coletada.emit()


func _ocultar_joia() -> void:
	if joia_visual:
		joia_visual.hide()


func _preparar_joia() -> void:
	for indice in malha_base.mesh.get_surface_count():
		var material := malha_base.mesh.surface_get_material(indice)
		if material == null or material.resource_name != "Bau_Joia":
			continue

		var dados := malha_base.mesh.surface_get_arrays(indice)
		var vertices: PackedVector3Array = dados[Mesh.ARRAY_VERTEX]
		if vertices.is_empty():
			return

		var malha_joia := ArrayMesh.new()
		malha_joia.add_surface_from_arrays(malha_base.mesh.surface_get_primitive_type(indice), dados)
		malha_joia.surface_set_material(0, material)

		var limites := AABB(vertices[0], Vector3.ZERO)
		for vertice in vertices:
			limites = limites.expand(vertice)
		var centro := limites.get_center()

		joia_visual = MeshInstance3D.new()
		joia_visual.name = "JoiaAmpliada"
		joia_visual.mesh = malha_joia
		joia_visual.scale = Vector3.ONE * escala_joia
		joia_visual.position = centro * (1.0 - escala_joia)
		malha_base.add_child(joia_visual)

		var invisivel := StandardMaterial3D.new()
		invisivel.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		invisivel.albedo_color.a = 0.0
		malha_base.set_surface_override_material(indice, invisivel)
		return
