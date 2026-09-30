class_name HealthComponentFPS
extends Node

signal health_changed(current: float, max: float)
signal died

@export var max_health: float = 100.0

var _death_emitted: bool = false
var current_health: float:
	set(value):
		var was_alive := current_health > 0.0
		current_health = clamp(value, 0.0, max_health)
		health_changed.emit(current_health, max_health)
		if was_alive and current_health <= 0.0 and not _death_emitted:
			_death_emitted = true
			died.emit()

func _ready() -> void:
	configure(max_health)


func configure(value: float) -> void:
	max_health = maxf(value, 0.0)
	_death_emitted = false
	current_health = max_health


func take_damage(amount: float) -> void:
	if amount <= 0.0 or current_health <= 0.0:
		return
	var entity := get_parent()
	var entity_type := "Entity"
	if entity.is_in_group("player"):
		entity_type = "Player"
	elif entity.is_in_group("enemy_fps"):
		entity_type = "Enemy"
	print("[Damage] %s '%s' recibe %.2f de daño (vida: %.2f/%.2f)" % [
		entity_type,
		entity.name,
		amount,
		maxf(current_health - amount, 0.0),
		max_health,
	])
	current_health -= amount


func heal(amount: float) -> void:
	if amount <= 0.0:
		return
	current_health += amount


func is_dead() -> bool:
	return current_health <= 0.0
