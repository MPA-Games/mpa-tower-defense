class_name AttackModifiersFPS
extends Node

signal modifier_duration_changed(slot: int, time_remaining: float, duration: float)

var _modifiers: Dictionary = {}

func apply_definition(definition: ConsumableDefinitionFPS, slot: int) -> void:
	if definition == null or definition.attack_modifier_id.is_empty():
		return
	var modifier_id := definition.attack_modifier_id
	var modifier: AttackModifierFPS = _modifiers.get(modifier_id)
	if modifier == null:
		modifier = AttackModifierFPS.new(modifier_id)
		_modifiers[modifier_id] = modifier
	modifier.activate(
		definition.projectile_count,
		definition.projectile_spread_degrees,
		definition.duration_seconds,
		slot,
		definition.projectile_scene,
	)
	modifier_duration_changed.emit(slot, modifier.time_remaining, modifier.duration)

func modify(context: AttackContextFPS) -> void:
	for modifier: AttackModifierFPS in _modifiers.values():
		modifier.modify(context)

func _process(delta: float) -> void:
	var expired_ids: Array[StringName] = []
	for modifier_id: StringName in _modifiers:
		var modifier: AttackModifierFPS = _modifiers[modifier_id]
		modifier.tick(delta)
		modifier_duration_changed.emit(
			modifier.slot,
			modifier.time_remaining,
			modifier.duration,
		)
		if not modifier.is_active():
			expired_ids.append(modifier_id)
	for modifier_id in expired_ids:
		_modifiers.erase(modifier_id)
