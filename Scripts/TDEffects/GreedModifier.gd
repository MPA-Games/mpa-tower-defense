extends StatusEffect
class_name GreedModifier

@export var goldMultiplier: float = 1.5

func _init() -> void:
	effect_id = &"greed"

func get_stat_multiplier(stat: StringName) -> float:
	if stat == &"gold_reward":
		return goldMultiplier

	return 1.0
