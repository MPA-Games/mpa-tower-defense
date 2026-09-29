extends Resource
class_name StatusEffect

@export var effect_id: StringName
@export var duration: float = 0.0
@export var tick_interval: float = 0.0

func get_stat_multiplier(_stat: StringName) -> float:
	return 1.0

func on_tick(_target: Enemy) -> void:
	pass
