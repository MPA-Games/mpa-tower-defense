extends Node

func show_combo_activated(combo_id: StringName, target: Enemy) -> void:
	if not is_instance_valid(target):
		return

	var label := Label3D.new()

	label.text = _get_combo_text(combo_id)
	label.font_size = 48
	label.outline_size = 8
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true

	get_tree().current_scene.add_child(label)

	label.global_position = target.global_position + Vector3(0, 2.2, 0)

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		label,
		"global_position",
		label.global_position + Vector3.UP * 1.2,
		0.8
	)

	tween.tween_property(
		label,
		"modulate:a",
		0.0,
		0.8
	)

	tween.set_parallel(false)
	tween.tween_callback(label.queue_free)
	
	if combo_id == &"dps_electro":
		_show_explosion(target)


func _get_combo_text(combo_id: StringName) -> String:
	match combo_id:
		&"dps_electro":
			return "DPS + ELECTRO"

		&"dps_slow":
			return "DPS + SLOW"

		&"dps_greed":
			return "DPS + GREED"

		&"electro_slow":
			return "ELECTRO + SLOW"

		&"electro_greed":
			return "ELECTRO + GREED"

		&"slow_greed":
			return "SLOW + GREED"

	return str(combo_id)

func _show_explosion(target: Enemy) -> void:
	if not is_instance_valid(target):
		return

	var sphere := MeshInstance3D.new()
	var mesh := SphereMesh.new()

	mesh.radius = 1.0
	mesh.height = 2.0
	sphere.mesh = mesh

	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.3, 0.7, 1.0, 0.35)

	sphere.material_override = material

	get_tree().current_scene.add_child(sphere)
	sphere.global_position = target.global_position

	sphere.scale = Vector3.ONE * 0.2

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		sphere,
		"scale",
		Vector3.ONE * 3.0,
		0.35
	)

	tween.tween_property(
		material,
		"albedo_color",
		Color(0.3, 0.7, 1.0, 0.0),
		0.35
	)

	tween.set_parallel(false)
	tween.tween_callback(sphere.queue_free)
