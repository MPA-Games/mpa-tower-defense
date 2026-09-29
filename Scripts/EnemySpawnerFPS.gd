class_name EnemySpawnerFPS
extends Node

@export var enemy_scene: PackedScene

var spawn_points: Array[Node3D] = []

func _ready() -> void:
	for child in get_children():
		if child is Node3D:
			spawn_points.append(child)
	_spawn_all()

func _spawn_all() -> void:
	if enemy_scene == null or spawn_points.is_empty():
		push_warning("EnemySpawnerFPS: falta enemy_scene o spawn_points.")
		return

	var available_points := spawn_points.duplicate()
	available_points.shuffle()
	var next_point_index := 0

	for entry in SpawnConfigFPS.spawn_list:
		for i in entry.amount:
			var point := _next_spawn_point(available_points, next_point_index)
			next_point_index += 1
			_spawn_one(entry.enemy_type, point)

func _next_spawn_point(points: Array, index: int) -> Node3D:
	return points[index % points.size()]

func _spawn_one(enemy_type: EnemyTypeFPS, point: Node3D) -> void:
	var instance: EnemyFPS = enemy_scene.instantiate()
	instance.enemy_type = enemy_type
	get_tree().current_scene.add_child.call_deferred(instance)
	instance.set_deferred("global_position", point.global_position)
