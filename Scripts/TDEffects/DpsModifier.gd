extends StatusEffect
class_name DpsModifier

@export var damagePerTick: float = 1.0

func _init() -> void:
	effect_id = &"dps"

func on_tick(target: Enemy) -> void:
	target.takeDamage(damagePerTick)
