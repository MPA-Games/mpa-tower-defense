extends ComboEffect
class_name DpsGreedEffect

@export var damagePerGold: float = 0.01
@export var maxBonusDamage: float = 10.0

func _init() -> void:
	tickInterval = 1.0

func tick(target: Enemy, _runtime: Dictionary) -> void:
	if not is_instance_valid(target):
		return

	var bonusDamage: float = Game.gold * damagePerGold
	bonusDamage = min(bonusDamage, maxBonusDamage)

	target.takeDamage(bonusDamage)
