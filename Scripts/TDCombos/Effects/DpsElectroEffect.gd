extends ComboEffect
class_name DpsElectroEffect

@export var explosionDamage: float = 5.0
@export var explosionRadius: float = 2.5
@export var maxTargets: int = 32


func activate(target: Enemy, _runtime: Dictionary) -> void:
	if not is_instance_valid(target):
		return

	var sphere := SphereShape3D.new()
	sphere.radius = explosionRadius

	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = sphere
	query.transform = Transform3D(
		Basis.IDENTITY,
		target.global_position
	)

	query.collision_mask = 2
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var spaceState := target.get_world_3d().direct_space_state
	var results := spaceState.intersect_shape(query, maxTargets)

	for result in results:
		var enemy := result.collider as Enemy

		if enemy == null:
			continue

		enemy.takeDamage(explosionDamage)
