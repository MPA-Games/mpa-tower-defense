class_name EffectControllerFPS
extends Node

@export var movement: PlayerMovementComponent
@export var sway: CameraSway
@export var attack_modifiers: AttackModifiersFPS
@export var effect_owner: Node3D
@export var attached_objects: Node3D

signal effect_duration_changed(slot: int, time_remaining: float, duration: float)

var _speed_time_remaining: float = 0.0
var _speed_duration: float = 0.0
var _speed_slot: int = -1
var _speed_multiplier: float = 1.0
var _dizzy_charges: Array[Dictionary] = []
var _active_area_effects: Dictionary[String, AreaEffectFPS] = {}

func apply_consumable(definition: ConsumableDefinitionFPS, slot: int = -1) -> void:
	if definition == null:
		return
	if definition.speed_multiplier > 1.0:
		_speed_multiplier = definition.speed_multiplier
		_speed_time_remaining = definition.duration_seconds
		_speed_duration = definition.duration_seconds
		_speed_slot = slot
		movement.set_speed_multiplier(_speed_multiplier)
		effect_duration_changed.emit(_speed_slot, _speed_time_remaining, _speed_duration)
	if definition.dizzy_amount > 0.0:
		_dizzy_charges.append({
			"time_remaining": definition.duration_seconds,
			"amount": definition.dizzy_amount,
		})
		_refresh_dizzy()
	if definition.effect_type == &"slow" and definition.effect_radius > 0.0:
		_apply_area_effect(definition, slot)
	if attack_modifiers:
		attack_modifiers.apply_definition(definition, slot)

func configure_attack_modifiers(modifiers: AttackModifiersFPS) -> void:
	attack_modifiers = modifiers
	attack_modifiers.modifier_duration_changed.connect(
		func(slot: int, time_remaining: float, duration: float):
			effect_duration_changed.emit(slot, time_remaining, duration)
	)

func _process(delta: float) -> void:
	if _speed_time_remaining > 0.0:
		_speed_time_remaining = maxf(_speed_time_remaining - delta, 0.0)
		effect_duration_changed.emit(_speed_slot, _speed_time_remaining, _speed_duration)
		if is_zero_approx(_speed_time_remaining):
			_speed_multiplier = 1.0
			movement.set_speed_multiplier(_speed_multiplier)
			_speed_duration = 0.0
			_speed_slot = -1
	for charge in _dizzy_charges:
		charge["time_remaining"] = maxf(charge["time_remaining"] - delta, 0.0)
	_dizzy_charges = _dizzy_charges.filter(func(charge: Dictionary): return charge["time_remaining"] > 0.0)
	_refresh_dizzy()

func _apply_area_effect(definition: ConsumableDefinitionFPS, slot: int) -> void:
	if effect_owner == null or attached_objects == null or definition.area_effect_scene == null:
		return
	var effect_key := String(definition.item_id)
	if _active_area_effects.has(effect_key):
		var existing: AreaEffectFPS = _active_area_effects[effect_key]
		if existing != null and is_instance_valid(existing):
			existing.queue_free()
		_active_area_effects.erase(effect_key)
	var effect := definition.area_effect_scene.instantiate() as AreaEffectFPS
	if effect == null:
		return
	effect.configure(effect_owner, definition.effect_radius, definition.duration_seconds)
	effect.configure_from_definition(definition)
	attached_objects.add_child(effect)
	_active_area_effects[effect_key] = effect
	effect.duration_changed.connect(
		func(time_remaining: float, duration: float):
			effect_duration_changed.emit(slot, time_remaining, duration)
	)
	effect.expired.connect(
		func():
			_active_area_effects.erase(effect_key)
	)
	effect_duration_changed.emit(slot, definition.duration_seconds, definition.duration_seconds)

func _refresh_dizzy() -> void:
	var total_dizzy := 0.0
	for charge in _dizzy_charges:
		total_dizzy += charge["amount"]
	sway.set_dizzy_intensity(total_dizzy)
