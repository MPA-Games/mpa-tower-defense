class_name EnemySpawnerFPS
extends Node

@export var enemy_scene: PackedScene
@export_range(0.0, 100.0, 0.1) var minimum_spawn_distance := 2.0
@export_range(1, 100, 1) var max_position_attempts := 24
@export_range(1, 8, 1) var enemies_per_frame := 2

var spawn_zones: Array[SpawnZoneFPS] = []
var random_number_generator := RandomNumberGenerator.new()

func _ready() -> void:
	for child in get_children():
		if child is SpawnZoneFPS:
			spawn_zones.append(child)
	_spawn_all()

func _spawn_all() -> void:
	if enemy_scene == null or spawn_zones.is_empty():
		push_warning("EnemySpawnerFPS: falta enemy_scene o SpawnZoneFPS.")
		return

	random_number_generator.randomize()
	var selected_positions: Array[Vector3] = []

	for entry in SpawnConfigFPS.spawn_list:
		for enemy_index in entry.amount:
			var spawn_position: Variant = _next_spawn_position(selected_positions)
			if spawn_position == null:
				return
			selected_positions.append(spawn_position)
			_spawn_one(entry.enemy_type, spawn_position)
			if (enemy_index + 1) % enemies_per_frame == 0:
				await get_tree().process_frame

func _next_spawn_position(selected_positions: Array[Vector3]) -> Variant:
	var best_position: Variant = null
	var best_distance := -1.0

	for _attempt in max_position_attempts:
		var zone := spawn_zones[random_number_generator.randi_range(0, spawn_zones.size() - 1)]
		var candidate: Variant = zone.sample_global_position(random_number_generator)
		if candidate == null:
			continue

		var nearest_distance := _nearest_distance(candidate, selected_positions)
		if nearest_distance >= minimum_spawn_distance:
			return candidate
		if nearest_distance > best_distance:
			best_distance = nearest_distance
			best_position = candidate

	if best_position != null:
		push_warning("EnemySpawnerFPS: no hay espacio suficiente para respetar minimum_spawn_distance.")
	return best_position

func _nearest_distance(candidate: Vector3, selected_positions: Array[Vector3]) -> float:
	if selected_positions.is_empty():
		return INF

	var nearest_distance := INF
	for selected_position in selected_positions:
		nearest_distance = min(nearest_distance, candidate.distance_to(selected_position))
	return nearest_distance

func _spawn_one(enemy_type: EnemyTypeFPS, spawn_position: Vector3) -> void:
	var instance: EnemyFPS = enemy_scene.instantiate()
	instance.enemy_type = enemy_type
	get_tree().current_scene.add_child.call_deferred(instance)
	instance.set_deferred("global_position", spawn_position)
