extends Node

var hazards: Array[Dictionary] = []


func _ready() -> void:
	set_process(false)


func add_damage_hazard(
	position: Vector3,
	radius: float,
	damagePerTick: float,
	duration: float,
	tickInterval: float,
	maxTargets: int = 32
) -> void:

	var sphere := SphereShape3D.new()
	sphere.radius = radius

	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = sphere
	query.transform = Transform3D(Basis.IDENTITY, position)
	query.collision_mask = 2
	query.collide_with_bodies = true
	query.collide_with_areas = false
	var visual := _create_hazard_visual(position, radius)
	hazards.append({
		"query": query,
		"damage": damagePerTick,
		"time_left": duration,
		"tick_interval": tickInterval,
		"tick_elapsed": 0.0,
		"max_targets": maxTargets,
		"visual": visual
	})

	set_process(true)


func _process(delta: float) -> void:
	for i in range(hazards.size() - 1, -1, -1):
		var hazard: Dictionary = hazards[i]

		hazard["time_left"] -= delta
		hazard["tick_elapsed"] += delta

		while hazard["tick_elapsed"] >= hazard["tick_interval"]:
			hazard["tick_elapsed"] -= hazard["tick_interval"]
			_apply_damage(hazard)

		if hazard["time_left"] <= 0.0:
			var visual: MeshInstance3D = hazard["visual"]

			if is_instance_valid(visual):
				visual.queue_free()

			hazards.remove_at(i)

	if hazards.is_empty():
		set_process(false)


func _apply_damage(hazard: Dictionary) -> void:
	var currentScene := get_tree().current_scene as Node3D

	if currentScene == null:
		return

	var world: World3D = currentScene.get_world_3d()

	if world == null:
		return

	var results: Array[Dictionary] = world.direct_space_state.intersect_shape(
		hazard["query"],
		hazard["max_targets"]
	)

	for result: Dictionary in results:
		var enemy := result["collider"] as Enemy

		if enemy == null:
			continue

		enemy.takeDamage(hazard["damage"])

func _create_hazard_visual(position: Vector3, radius: float) -> MeshInstance3D:
	var visual := MeshInstance3D.new()

	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.05
	mesh.radial_segments = 24

	visual.mesh = mesh

	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.45, 0.15, 0.55, 0.45)

	visual.material_override = material

	get_tree().current_scene.add_child(visual)

	visual.global_position = position + Vector3(0, 0.03, 0)

	return visual
