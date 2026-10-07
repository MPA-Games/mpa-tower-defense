class_name WandFPS
extends Node

@export var bullet_scene: PackedScene
@export var fire_action: String = "fire"
@export var cooldown: float = 0.25
@export var bullet_speed: float = 30.0
@export var damage: float = 20.0
@export var attack_modifiers: AttackModifiersFPS

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
	var attack := AttackContextFPS.new()
	attack.aim_point = aim_point
	attack.bullet_speed = bullet_speed
	attack.damage = damage
	attack.projectile_scene = bullet_scene
	if attack_modifiers:
		attack_modifiers.modify(attack)
	if attack.projectile_scene == null:
		attack.projectile_scene = bullet_scene

	for projectile_index in attack.projectile_count:
		_spawn_projectile(attack, projectile_index)

	_cooldown_remaining = cooldown

func _spawn_projectile(attack: AttackContextFPS, projectile_index: int) -> void:
	var projectile_scene_to_use: PackedScene = attack.projectile_scene if attack.projectile_scene != null else bullet_scene
	var bullet: BulletFPS = projectile_scene_to_use.instantiate() as BulletFPS
	if bullet == null:
		bullet = bullet_scene.instantiate() as BulletFPS
	if bullet == null:
		return
	print("[WandFPS] disparando bala: %s | default=%s | override=%s" % [
		bullet.get_script().resource_path if bullet.get_script() != null else "<sin script>",
		bullet_scene.resource_path if bullet_scene != null else "<null>",
		attack.projectile_scene.resource_path if attack.projectile_scene != null else "<null>"
	])
	bullet.speed = attack.bullet_speed
	bullet.damage = attack.damage
	if shooter:
		bullet.set_shooter(shooter)

	get_tree().current_scene.add_child(bullet)
	bullet.global_position = muzzle.global_position
	var direction := (attack.aim_point - muzzle.global_position).normalized()
	if attack.projectile_count > 1 and attack.spread_degrees > 0.0:
		var center_index := (attack.projectile_count - 1) * 0.5
		var spread_offset := (projectile_index - center_index) * attack.spread_degrees
		var spread_axis := aim_origin.global_transform.basis.y.normalized()
		direction = direction.rotated(spread_axis, deg_to_rad(spread_offset)).normalized()
	bullet.look_at(muzzle.global_position + direction, Vector3.UP)

func _get_aim_point() -> Vector3:
	var from: Vector3 = aim_origin.global_position
	var to: Vector3 = from + (-aim_origin.global_transform.basis.z) * max_aim_distance

	var space_state := aim_origin.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	if shooter is CollisionObject3D:
		query.exclude = [shooter.get_rid()]

	var result := space_state.intersect_ray(query)
	return result.position if result else to
