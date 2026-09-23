class_name CameraSway
extends Node

# This script applies a subtle sway effect to the camera based on time and player stats, simulating motion sickness or movement effects.

@export var camera: Node3D
@export var stats: PlayerStats

var _time: float = 0.0
var _base_rotation: Vector3

func _ready() -> void:
	if camera:
		_base_rotation = camera.rotation


## Permite a otro sistema (ej: pociones) subir o bajar el mareo en runtime,
## sin que este script sepa nada de pociones.
func set_intensity(value: float) -> void:
	if stats:
		stats.sway_intensity = value


func _process(delta: float) -> void:
	if camera == null or stats == null or stats.sway_intensity <= 0.0:
		return

	_time += delta * stats.sway_speed

	var offset := Vector3(
		sin(_time * 1.3) * 0.02,
		sin(_time * 2.1) * 0.015,
		sin(_time * 0.9) * 0.01
	) * stats.sway_intensity

	camera.rotation = _base_rotation + offset