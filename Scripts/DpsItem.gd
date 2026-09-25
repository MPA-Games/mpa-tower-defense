extends Item
class_name DpsItem

@export var dpsDuration: float
@export var dpsDamage: float
@export var dpsTick: float

func apply_effect(target: Enemy) -> void:
	var dpsModifier := DpsModifier.new()

	dpsModifier.damagePerTick = dpsDamage
	dpsModifier.duration = dpsDuration
	dpsModifier.tick_interval = dpsTick

	target.statusEffectController.add_effect(dpsModifier, item_id)
