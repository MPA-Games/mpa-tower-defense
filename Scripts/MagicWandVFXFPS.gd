class_name MagicWandVFXFPS
extends Node3D

func _ready() -> void:
	var particles: Array[GPUParticles3D] = []
	for child in find_children("*", "GPUParticles3D", true, false):
		particles.append(child as GPUParticles3D)

	if particles.is_empty():
		queue_free()
		return

	var longest_lifetime := 0.0
	for particle in particles:
		particle.emitting = true
		particle.restart()
		longest_lifetime = maxf(longest_lifetime, particle.lifetime)

	await get_tree().create_timer(longest_lifetime + 0.2).timeout
	queue_free()
