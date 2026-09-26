extends ComboEffect
class_name SlowGreedEffect

func _init() -> void:
	tickInterval = 1.0

func tick(target: Enemy, _runtime: Dictionary) -> void:
	if not is_instance_valid(target):
		return

	Game.add_gold(1)
