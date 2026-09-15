extends Item
class_name SlowItem

@export var slowMultiplier: float = 0.5
@export var slowDuration: float = 2.0

func apply_effect(target: Enemy) -> void:
	target.apply_slow(slowMultiplier, slowDuration)
