class_name SlowZoneFPS
extends AreaEffectFPS

@export var slow_multiplier: float = 0.5

func configure_from_definition(definition: ConsumableDefinitionFPS) -> void:
	if definition != null:
		slow_multiplier = definition.slow_multiplier

func apply_to_target(target: Node3D) -> void:
	if target == null:
		return
	var movement := target.get_node_or_null("Movement") as EnemyMovementFPS
	if movement == null:
		push_warning("SlowZoneFPS: el objetivo %s no tiene EnemyMovementFPS en Movement." % target.name)
		return
	movement.apply_speed_modifier(&"slow_zone", slow_multiplier)
	print("[SlowZoneFPS] slow aplicado a %s | multiplicador=%.2f" % [target.name, slow_multiplier])

func remove_from_target(target: Node3D) -> void:
	if target == null:
		return
	var movement := target.get_node_or_null("Movement") as EnemyMovementFPS
	if movement == null:
		return
	movement.remove_speed_modifier(&"slow_zone")
	print("[SlowZoneFPS] slow removido de %s" % target.name)
