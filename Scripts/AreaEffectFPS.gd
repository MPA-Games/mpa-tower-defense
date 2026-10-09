class_name AreaEffectFPS
extends Node3D

signal duration_changed(time_remaining: float, duration: float)
signal expired

var effect_owner: Node3D
var radius: float = 5.0
var duration_seconds: float = 10.0
var _time_remaining: float = 0.0
var _affected_targets: Dictionary = {}

func configure(effect_owner_value: Node3D, effect_radius: float, duration: float) -> void:
	effect_owner = effect_owner_value
	radius = maxf(effect_radius, 0.1)
	duration_seconds = maxf(duration, 0.0)
	_time_remaining = duration_seconds

func configure_from_definition(_definition: ConsumableDefinitionFPS) -> void:
	pass

func _process(delta: float) -> void:
	if effect_owner != null and is_inside_tree():
		global_position = effect_owner.global_position
	_time_remaining = maxf(_time_remaining - delta, 0.0)
	duration_changed.emit(_time_remaining, duration_seconds)
	if _time_remaining <= 0.0:
		_cleanup_targets()
		expired.emit()
		queue_free()
		return
	_refresh_targets()

func _refresh_targets() -> void:
	if get_tree() == null:
		return
	var nearby_targets: Dictionary = {}
	for target in get_tree().get_nodes_in_group("enemy_fps"):
		if target is Node3D:
			var enemy_target := target as Node3D
			if enemy_target.global_position.distance_to(global_position) <= radius:
				nearby_targets[enemy_target] = true
				if not _affected_targets.has(enemy_target):
					apply_to_target(enemy_target)
					_affected_targets[enemy_target] = true
	for target in _affected_targets.keys():
		if not is_instance_valid(target):
			_affected_targets.erase(target)
			continue
		if not nearby_targets.has(target):
			remove_from_target(target)
			_affected_targets.erase(target)

func apply_to_target(_target: Node3D) -> void:
	pass

func remove_from_target(_target: Node3D) -> void:
	pass

func _cleanup_targets() -> void:
	for target in _affected_targets.keys():
		if is_instance_valid(target):
			remove_from_target(target)
	_affected_targets.clear()
