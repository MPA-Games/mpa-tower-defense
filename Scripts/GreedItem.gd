extends Item
class_name GreedItem

@export var goldMultiplier: float
@export var greedDuration: float
@export var upgradeScaling: float = 1.0

func apply_effect(target: Enemy, context: EffectContext) -> void:
	var effectMultiplier := context.effectMultiplier
	var greedModifier := GreedModifier.new()

	var baseBonus := goldMultiplier - 1.0
	var adjustedMultiplier := 1.0 + (effectMultiplier - 1.0) * upgradeScaling

	greedModifier.goldMultiplier = 1.0 + (baseBonus * adjustedMultiplier)
	greedModifier.duration = greedDuration

	target.statusEffectController.add_effect(greedModifier, item_id)
