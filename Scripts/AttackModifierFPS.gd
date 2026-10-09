class_name AttackModifierFPS
extends RefCounted

var modifier_id: StringName
var projectile_count: int = 1
var spread_degrees: float = 0.0
var time_remaining: float = 0.0
var duration: float = 0.0
var slot: int = -1
var projectile_scene: PackedScene = null

func _init(id: StringName) -> void:
	modifier_id = id

func activate(
	new_projectile_count: int,
	new_spread_degrees: float,
	new_duration: float,
	new_slot: int,
	new_projectile_scene: PackedScene = null,
) -> void:
	projectile_count = maxi(new_projectile_count, 1)
	spread_degrees = maxf(new_spread_degrees, 0.0)
	duration = maxf(new_duration, 0.0)
	time_remaining = duration
	slot = new_slot
	projectile_scene = new_projectile_scene

func modify(context: AttackContextFPS) -> void:
	if not is_active():
		return
	context.projectile_count = maxi(context.projectile_count, projectile_count)
	context.spread_degrees = maxf(context.spread_degrees, spread_degrees)
	if projectile_scene != null:
		context.projectile_scene = projectile_scene

func tick(delta: float) -> void:
	time_remaining = maxf(time_remaining - delta, 0.0)

func is_active() -> bool:
	return time_remaining > 0.0
