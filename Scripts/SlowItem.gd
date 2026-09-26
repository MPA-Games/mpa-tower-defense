extends Item
class_name SlowItem

@export var slowMultiplier: float = 0.5
@export var slowDuration: float = 2.0
@export var upgradeScaling: float = 0.5

func apply_effect(target: Enemy, effectMultiplier: float = 1.0) -> void:
	var slowStrength := 1.0 - slowMultiplier

	var adjustedMultiplier := 1.0 + (effectMultiplier - 1.0) * upgradeScaling
	slowStrength *= adjustedMultiplier
	slowStrength = clamp(slowStrength, 0.0, 0.95)

	var slowModifier := SlowModifier.new()
	slowModifier.speedMultiplier = 1.0 - slowStrength
	slowModifier.duration = slowDuration

	target.statusEffectController.add_effect(slowModifier, item_id)
