extends Node
class_name StatusEffectController

var activeEffects: Dictionary = {}

func has_effect(effect_id: StringName) -> bool:
	return activeEffects.has(effect_id)

func get_effect_count() -> int:
	return activeEffects.size()

func add_effect(effect: StatusEffect, sourceItemId: StringName) -> void:
	if effect.effect_id == &"":
		push_warning("StatusEffect sin effect_id")
		return

	if activeEffects.has(effect.effect_id):
		activeEffects[effect.effect_id]["time_left"] = effect.duration
		return

	activeEffects[effect.effect_id] = {
		"effect": effect,
		"source_item_id": sourceItemId,
		"time_left": effect.duration,
		"tick_elapsed": 0.0
	}

func _process(delta: float) -> void:
	var target := get_parent() as Enemy
	if target == null:
		return

	var expiredEffects: Array[StringName] = []

	for effect_id in activeEffects:
		var data: Dictionary = activeEffects[effect_id]
		var effect: StatusEffect = data["effect"]

		var timeLeft: float = data["time_left"]
		var activeDelta: float = min(delta, max(timeLeft, 0.0))

		data["time_left"] -= delta

		if effect.tick_interval > 0.0:
			data["tick_elapsed"] += activeDelta

			while data["tick_elapsed"] >= effect.tick_interval:
				data["tick_elapsed"] -= effect.tick_interval
				effect.on_tick(target)

				if target.is_queued_for_deletion():
					return

		if data["time_left"] <= 0.0:
			expiredEffects.append(effect_id)

	for effect_id in expiredEffects:
		activeEffects.erase(effect_id)

func get_stat_multiplier(stat: StringName) -> float:
	var multiplier: float = 1.0

	for data in activeEffects.values():
		var effect: StatusEffect = data["effect"]
		multiplier *= effect.get_stat_multiplier(stat)
	return multiplier

func has_item_effect(itemId: StringName) -> bool:
	for data in activeEffects.values():
		if data["source_item_id"] == itemId:
			return true

	return false
