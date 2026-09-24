class_name BulletFPS
extends Node3D

@export var speed: float = 30.0
@export var damage: float = 20.0
@export var lifetime: float = 3.0
@export var impact_vfx_scene: PackedScene

var _shooter_rid: RID
var _has_shooter: bool = false
var _time_alive: float = 0.0

func set_shooter(shooter: Node3D) -> void:
	if shooter is CollisionObject3D:
		_shooter_rid = shooter.get_rid()
		_has_shooter = true


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
		_on_hit(result.collider, result.position, result.normal)
	else:
		global_position = to


func _on_hit(collider: Object, hit_position: Vector3, hit_normal: Vector3) -> void:
	if collider.has_method("take_damage"):
		collider.take_damage(damage)

	_spawn_impact_vfx(hit_position, hit_normal)
	queue_free()


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
