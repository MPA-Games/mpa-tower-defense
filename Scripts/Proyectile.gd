extends Node3D

class_name Proyectile

var target: Enemy
var damage: float
@export var speed: float
var equippedItem: Item = null

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		queue_free()
		return
	
	global_position = global_position.move_toward(target.global_position, speed * delta)
	
	if global_position.distance_to(target.global_position) < 0.3:
		target.takeDamage(damage)
		if equippedItem:
			equippedItem.apply_effect(target)
		queue_free()
