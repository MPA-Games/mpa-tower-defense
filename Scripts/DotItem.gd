extends Item
class_name DotItem

@export var dotDuration: float
@export var dotDamage: float
@export var dotTick: float

func apply_effect(target: Enemy) -> void:
	target.apply_dot(dotDamage, dotDuration,dotTick)
