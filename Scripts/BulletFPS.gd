class_name BulletFPS
extends Node3D

@export var speed: float = 30.0
@export var damage: float = 20.0
@export var headshot_multiplier: float = 2.0
@export var lifetime: float = 3.0
@export var impact_vfx_scene: PackedScene

var _shooter_rid: RID
var _has_shooter: bool = false
var _shooter: Node3D
var _shooter_faction: int = DamageFactions.Faction.NEUTRAL
var _time_alive: float = 0.0

func set_shooter(shooter: Node3D) -> void:
	_shooter = shooter
	if shooter is CollisionObject3D:
		_shooter_rid = shooter.get_rid()
		_has_shooter = true
		var shooter_receiver := shooter.get_node_or_null("DamageReceiver") as DamageReceiver
		if shooter_receiver != null:
			_shooter_faction = shooter_receiver.faction


func _physics_process(delta: float) -> void:
	_time_alive += delta
	if _time_alive >= lifetime:
		queue_free()
		return

	var motion: Vector3 = -global_transform.basis.z * speed * delta
	var from: Vector3 = global_position
	var to: Vector3 = from + motion

	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	if _has_shooter:
		query.exclude = [_shooter_rid]

	var result := space_state.intersect_ray(query)
	if result:
		_on_hit(
			result.collider,
			result.position,
			result.normal,
			int(result.get("shape", -1)),
		)
	else:
		global_position = to


func _on_hit(
	collider: Object,
	hit_position: Vector3,
	hit_normal: Vector3,
	shape_index: int,
) -> void:
	if collider is Node:
		var receiver := collider.get_node_or_null("DamageReceiver") as DamageReceiver
		if receiver != null:
			var hit_damage := damage
			var is_headshot: bool = collider is EnemyFPS and collider.is_head_shape(shape_index)
			if is_headshot:
				hit_damage *= headshot_multiplier
				print("[Critical] Headshot a '%s': %.2f de daño" % [collider.name, hit_damage])
			receiver.receive_damage(DamageContext.new(hit_damage, self, _shooter_faction))
			if receiver.faction == DamageFactions.Faction.ENEMY and _shooter_faction == DamageFactions.Faction.PLAYER:
				_show_hitmarker(is_headshot)

	_spawn_impact_vfx(hit_position, hit_normal)
	queue_free()

func _show_hitmarker(is_critical: bool) -> void:
	var crosshair := get_tree().get_first_node_in_group("crosshair_fps") as CrosshairFPS
	if crosshair != null:
		crosshair.show_hitmarker(is_critical)


func _spawn_impact_vfx(hit_position: Vector3, hit_normal: Vector3) -> void:
	if impact_vfx_scene == null:
		return

	var vfx: Node3D = impact_vfx_scene.instantiate()
	get_tree().current_scene.add_child(vfx)
	vfx.global_position = hit_position
	if hit_normal.length() > 0.01:
		var up_direction: Vector3 = Vector3.UP
		if absf(hit_normal.normalized().dot(up_direction)) > 0.99:
			up_direction = Vector3.RIGHT
		vfx.global_transform = vfx.global_transform.looking_at(
			hit_position + hit_normal, up_direction
		)
