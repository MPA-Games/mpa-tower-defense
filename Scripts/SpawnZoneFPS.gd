class_name SpawnZoneFPS
extends Area3D

@onready var collision_shape: CollisionShape3D = get_node_or_null("CollisionShape3D")

func sample_global_position(random_number_generator: RandomNumberGenerator) -> Variant:
	if collision_shape == null or collision_shape.shape == null:
		return null

	var shape: Shape3D = collision_shape.shape
	var local_position: Vector3

	if shape is BoxShape3D:
		var box_shape: BoxShape3D = shape
		var half_size: Vector3 = box_shape.size * 0.5
		local_position = Vector3(
			random_number_generator.randf_range(-half_size.x, half_size.x),
			random_number_generator.randf_range(-half_size.y, half_size.y),
			random_number_generator.randf_range(-half_size.z, half_size.z)
		)
	elif shape is SphereShape3D:
		local_position = _sample_sphere(shape.radius, random_number_generator)
	else:
		return null

	return global_transform * collision_shape.transform * local_position

func _sample_sphere(radius: float, random_number_generator: RandomNumberGenerator) -> Vector3:
	var direction := Vector3(
		random_number_generator.randf_range(-1.0, 1.0),
		 random_number_generator.randf_range(-1.0, 1.0),
		 random_number_generator.randf_range(-1.0, 1.0)
	)

	while direction.length_squared() > 1.0 or direction.is_zero_approx():
		direction = Vector3(
			random_number_generator.randf_range(-1.0, 1.0),
			random_number_generator.randf_range(-1.0, 1.0),
			random_number_generator.randf_range(-1.0, 1.0)
		)

	return direction * radius * pow(random_number_generator.randf(), 1.0 / 3.0)
