extends Item
class_name DpsItem

@export var dpsDuration: float
@export var dpsDamage: float
@export var dpsTick: float

func apply_effect(target: Enemy) -> void:
	target.apply_dps(dpsDamage, dpsDuration,dpsTick)
