extends ComboEffect
class_name SlowGreedEffect

@export var goldPerTick: float = 1.0
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

	runtime["final_gold_per_tick"] = goldPerTick * adjustedPower
	runtime["gold_accumulator"] = 0.0


func tick(_target: Enemy, runtime: Dictionary) -> void:
	var finalGoldPerTick: float = runtime.get(
		"final_gold_per_tick",
		goldPerTick
	)

	var accumulator: float = runtime.get(
		"gold_accumulator",
		0.0
	)

	accumulator += finalGoldPerTick

	var goldToGive: int = floori(accumulator)

	if goldToGive > 0:
		Game.add_gold(goldToGive)
		accumulator -= goldToGive

	runtime["gold_accumulator"] = accumulator
