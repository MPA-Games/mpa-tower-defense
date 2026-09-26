extends ComboEffect
class_name DpsSlowEffect

@export var hazardRadius: float = 1.2
@export var damagePerTick: float = 2.0
@export var hazardDuration: float = 2.5
@export var hazardTickInterval: float = 0.5
@export var minDropDistance: float = 0.8
@export var maxTargets: int = 32


func _init() -> void:
	tickInterval = 0.4


func activate(target: Enemy, runtime: Dictionary) -> void:
	if not is_instance_valid(target):
		return

	_drop_hazard(target, runtime)


func tick(target: Enemy, runtime: Dictionary) -> void:
	if not is_instance_valid(target):
		return

	if runtime.has("last_position"):
		var lastPosition: Vector3 = runtime["last_position"]

		if target.global_position.distance_to(lastPosition) < minDropDistance:
			return

	_drop_hazard(target, runtime)


func _drop_hazard(target: Enemy, runtime: Dictionary) -> void:
	var position := target.global_position

	HazardManager.add_damage_hazard(
		position,
		hazardRadius,
		damagePerTick,
		hazardDuration,
		hazardTickInterval,
		maxTargets
	)

	runtime["last_position"] = position
