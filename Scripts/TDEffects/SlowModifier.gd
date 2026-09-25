extends StatusEffect
class_name SlowModifier

@export var speedMultiplier: float = 0.5

func _init() -> void:
	effect_id = &"slow"

func get_stat_multiplier(stat: StringName) -> float:
	if stat == &"move_speed":
		return speedMultiplier

	return 1.0
