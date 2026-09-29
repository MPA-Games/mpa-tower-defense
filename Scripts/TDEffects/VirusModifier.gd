extends StatusEffect
class_name VirusModifier

var speedMultiplier: float = 0.75
var stunDuration: float = 0.35

var spreadRadius: float = 3.5
var maxSpreadTargets: int = 2

var canSpread: bool = true

var spreadCount: int = 0


func _init() -> void:
	effect_id = &"virus"


func get_stat_multiplier(stat: StringName) -> float:
	if stat == &"move_speed":
		return speedMultiplier

	return 1.0


func on_tick(target: Enemy) -> void:
	if not is_instance_valid(target):
		return

	if target.isDead:
		return

	# Cada tick produce un pequeño stun.
	_apply_stun(target)

	# El virus original sigue intentando propagarse
	# hasta alcanzar el máximo de contagios.
	if canSpread and spreadCount < maxSpreadTargets:
		_spread(target)


func _apply_stun(target: Enemy) -> void:
	var stun := StunModifier.new()
	stun.duration = stunDuration

	# Este stun pertenece al virus.
	# No mandamos EffectContext para que NO cuente
	# como Electro y no genere combos artificiales.
	target.statusEffectController.call_deferred(
		"add_effect",
		stun,
		&"virus"
	)


func _spread(target: Enemy) -> void:

	var sphere := SphereShape3D.new()
	sphere.radius = spreadRadius

	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = sphere
	query.transform = Transform3D(
		Basis.IDENTITY,
		target.global_position
	)

	query.collision_mask = 2
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var spaceState := target.get_world_3d().direct_space_state

	var results := spaceState.intersect_shape(
		query,
		32
	)

	for result in results:
		var enemy := result.collider as Enemy

		if enemy == null:
			continue

		if enemy == target:
			continue

		if enemy.isDead:
			continue

		# No volvemos a infectar a alguien que ya tiene Virus.
		if enemy.statusEffectController.has_effect(&"virus"):
			continue

		var newVirus := VirusModifier.new()

		newVirus.duration = duration
		newVirus.tick_interval = tick_interval

		newVirus.speedMultiplier = speedMultiplier
		newVirus.stunDuration = stunDuration

		newVirus.spreadRadius = spreadRadius
		newVirus.maxSpreadTargets = maxSpreadTargets

		# MUY IMPORTANTE:
		# un enemigo contagiado NO vuelve a propagar.
		newVirus.canSpread = false

		enemy.statusEffectController.add_effect(
			newVirus,
			&"virus"
		)

		ComboFeedback.show_virus(
			enemy,
			newVirus.duration
		)

		spreadCount += 1

		if spreadCount >= maxSpreadTargets:
			break
