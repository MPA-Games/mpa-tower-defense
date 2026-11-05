class_name TargetStatusVFXFPS
extends Node3D

@onready var _smoke: GPUParticles3D = $Smoke

func configure(color: Color) -> void:
	var smoke_mesh := _smoke.draw_pass_1.duplicate() as Mesh
	if smoke_mesh == null:
		return
	var material := smoke_mesh.surface_get_material(0) as StandardMaterial3D
	if material == null:
		return
	material = material.duplicate() as StandardMaterial3D
	material.albedo_color = Color(color, 0.3)
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 0.25
	smoke_mesh.surface_set_material(0, material)
	_smoke.draw_pass_1 = smoke_mesh

	var process_material := _smoke.process_material.duplicate() as ParticleProcessMaterial
	if process_material == null:
		return
	process_material.color = Color(color, 0.3)
	_smoke.process_material = process_material
