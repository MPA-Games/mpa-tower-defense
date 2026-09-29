extends StatusEffect
class_name StunModifier

func _init() -> void:
	effect_id = &"stun"

func get_stat_multiplier(stat: StringName) -> float:
	if stat == &"move_speed":
		return 0.0

	return 1.0
