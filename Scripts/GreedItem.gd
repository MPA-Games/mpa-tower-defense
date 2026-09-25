extends Item
class_name GreedItem

@export var greedDuration: float = 5.0
@export var goldMultiplier: float = 1.5

func apply_effect(target: Enemy) -> void:
	var greedModifier := GreedModifier.new()

	greedModifier.duration = greedDuration
	greedModifier.goldMultiplier = goldMultiplier

	target.statusEffectController.add_effect(greedModifier, item_id)
