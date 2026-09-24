class_name WandFPS
extends Node

@export var bullet_scene: PackedScene
@export var fire_action: String = "fire"
@export var cooldown: float = 0.25
@export var bullet_speed: float = 30.0
@export var damage: float = 20.0

var shooter: Node3D

@export var muzzle: Marker3D
@export var aim_origin: Node3D
@export var max_aim_distance: float = 1000.0

var _cooldown_remaining: float = 0.0

func _process(delta: float) -> void:
	_cooldown_remaining = max(_cooldown_remaining - delta, 0.0)
	if Input.is_action_just_pressed(fire_action) and _cooldown_remaining <= 0.0:
		_fire()


func _fire() -> void:
	if bullet_scene == null or muzzle == null or aim_origin == null:
		push_warning("WandFPS: falta asignar bullet_scene, Muzzle o Aim Origin.")
		return

	var aim_point: Vector3 = _get_aim_point()

	var bullet: BulletFPS = bullet_scene.instantiate()
	bullet.speed = bullet_speed
	bullet.damage = damage
	if shooter:
		bullet.set_shooter(shooter)

	get_tree().current_scene.add_child(bullet)
	bullet.global_position = muzzle.global_position
	bullet.look_at(aim_point, Vector3.UP)

	_cooldown_remaining = cooldown

func _get_aim_point() -> Vector3:
	var from: Vector3 = aim_origin.global_position
	var to: Vector3 = from + (-aim_origin.global_transform.basis.z) * max_aim_distance

	var space_state := aim_origin.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	if shooter is CollisionObject3D:
		query.exclude = [shooter.get_rid()]

	var result := space_state.intersect_ray(query)
	return result.position if result else to
