extends Node

@export var spawn_list: Array[EnemySpawnEntryFPS] = []

func total_enemy_count() -> int:
	var total := 0
	for entry in spawn_list:
		total += entry.amount
	return total
	
