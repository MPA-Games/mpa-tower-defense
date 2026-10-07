class_name CameraSway
extends Node

# This script applies a subtle sway effect to the camera based on time and player stats, simulating motion sickness or movement effects.

@export var camera: Node3D
@export var stats: PlayerStats

var _time: float = 0.0
var _base_rotation: Vector3
var _base_intensity: float = 1.0
var _dizzy_intensity: float = 0.0

func _ready() -> void:
	if camera:
		_base_rotation = camera.rotation
	if stats:
		_base_intensity = stats.sway_intensity


func configure(new_camera: Node3D, new_stats: PlayerStats) -> void:
	camera = new_camera
	stats = new_stats
	_base_intensity = stats.sway_intensity


## Permite a otro sistema (ej: pociones) subir o bajar el mareo en runtime,
## sin que este script sepa nada de pociones.
func set_intensity(value: float) -> void:
	_base_intensity = maxf(value, 0.0)


func set_dizzy_intensity(value: float) -> void:
	_dizzy_intensity = maxf(value, 0.0)


func _process(delta: float) -> void:
	if camera == null or stats == null:
		return

	_time += delta * stats.sway_speed

	var offset := Vector3(
		sin(_time * 1.3) * 0.02,
		sin(_time * 2.1) * 0.015,
		sin(_time * 0.9) * 0.01
	) * (_base_intensity + _dizzy_intensity)

	camera.rotation = _base_rotation + offset