class_name ExplosiveBulletFPS
extends BulletFPS

@export var explosion_radius: float = 4.0
@export var explosion_damage: float = 25.0

func _on_hit(
	collider: Object,
	hit_position: Vector3,
	hit_normal: Vector3,
	shape_index: int,
) -> void:
	_apply_explosion(hit_position)
	super._on_hit(collider, hit_position, hit_normal, shape_index)

func _apply_explosion(hit_position: Vector3) -> void:
	if explosion_radius <= 0.0 or explosion_damage <= 0.0:
		return

	for enemy in get_tree().get_nodes_in_group("enemy_fps"):
		if not enemy is Node3D:
			continue
		var enemy_node := enemy as Node3D
		if enemy_node == null:
			continue
		var distance := enemy_node.global_position.distance_to(hit_position)
		if distance > explosion_radius:
			continue
		var receiver := enemy_node.get_node_or_null("DamageReceiver") as DamageReceiver
		if receiver == null:
			continue
		var falloff := 1.0 - (distance / maxf(explosion_radius, 0.001))
		var final_damage := explosion_damage * maxf(falloff, 0.0)
		receiver.receive_damage(DamageContext.new(final_damage, self, _shooter_faction))
