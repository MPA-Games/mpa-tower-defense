class_name HealthComponent
extends Node

signal health_changed(current: float, max: float)
signal died

@export var max_health: float = 100.0

var current_health: float:
	set(value):
		current_health = clamp(value, 0.0, max_health)
		health_changed.emit(current_health, max_health)
		if current_health <= 0.0:
			died.emit()

func _ready() -> void:
	current_health = max_health


func take_damage(amount: float) -> void:
	if amount <= 0.0 or current_health <= 0.0:
		return
	current_health -= amount


func heal(amount: float) -> void:
	if amount <= 0.0:
		return
	current_health += amount


func is_dead() -> bool:
	return current_health <= 0.0
