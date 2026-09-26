extends Item
class_name ShockItem

@export var shockDuration: float = 1.0
@export var upgradeScaling: float = 0.5

func apply_effect(target: Enemy, context: EffectContext) -> void:
	var effectMultiplier := context.effectMultiplier
	var stunModifier := StunModifier.new()

	var adjustedMultiplier := 1.0 + (effectMultiplier - 1.0) * upgradeScaling
	stunModifier.duration = shockDuration * adjustedMultiplier

	target.statusEffectController.add_effect(stunModifier, item_id)
