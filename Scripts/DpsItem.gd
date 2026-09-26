extends Item
class_name DpsItem

@export var dpsDuration: float
@export var dpsDamage: float
@export var dpsTick: float
@export var upgradeScaling: float = 1.0

func apply_effect(target: Enemy, effectMultiplier: float = 1.0) -> void:
	var dpsModifier := DpsModifier.new()

	var adjustedMultiplier := 1.0 + (effectMultiplier - 1.0) * upgradeScaling

	dpsModifier.damagePerTick = dpsDamage * adjustedMultiplier
	dpsModifier.duration = dpsDuration
	dpsModifier.tick_interval = dpsTick

	target.statusEffectController.add_effect(dpsModifier, item_id)
