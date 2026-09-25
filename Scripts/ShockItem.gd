extends Item
class_name ShockItem

@export var stunDuration: float = 1.0

func apply_effect(target: Enemy) -> void:
	var stunModifier := StunModifier.new()

	stunModifier.duration = stunDuration

	target.statusEffectController.add_effect(stunModifier, item_id)
