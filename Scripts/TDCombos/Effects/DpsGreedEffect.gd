extends ComboEffect
class_name DpsGreedEffect

@export var damagePerGold: float = 0.01
@export var maxBonusDamage: float = 10.0

@export var upgradeScaling: float = 1.0


func _init() -> void:
	tickInterval = 1.0


func activate(_target: Enemy, runtime: Dictionary) -> void:
	var comboPower: float = 1.0

	if runtime.has("combo_context"):
		var comboContext: ComboContext = runtime["combo_context"]

		if comboContext != null:
			comboPower = comboContext.powerMultiplier

	var adjustedPower := 1.0 + (comboPower - 1.0) * upgradeScaling

	runtime["final_damage_per_gold"] = damagePerGold * adjustedPower


func tick(target: Enemy, runtime: Dictionary) -> void:
	if not is_instance_valid(target):
		return

	var finalDamagePerGold: float = runtime.get(
		"final_damage_per_gold",
		damagePerGold
	)

	var bonusDamage: float = Game.gold * finalDamagePerGold
	bonusDamage = min(bonusDamage, maxBonusDamage)

	target.takeDamage(bonusDamage)
