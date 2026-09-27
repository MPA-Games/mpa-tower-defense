class_name ImpactVFXFPS
extends Node3D

@onready var _impact: GPUParticles3D = $Impact
@onready var _fire: GPUParticles3D = $Fire
@onready var _smoke: GPUParticles3D = $Smoke

func _ready() -> void:
	_impact.restart()
	_fire.restart()
	_smoke.restart()

	var duration: float = maxf(maxf(_impact.lifetime, _fire.lifetime), _smoke.lifetime)
	await get_tree().create_timer(duration + 0.2).timeout
	queue_free()
