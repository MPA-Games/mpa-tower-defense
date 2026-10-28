extends Resource
class_name ComboEffect

@export var tickInterval: float = 0.0


func can_activate(_target: Enemy) -> bool:
	return true


func activate(_target: Enemy, _runtime: Dictionary) -> void:
	pass


func tick(_target: Enemy, _runtime: Dictionary) -> void:
	pass


func deactivate(_target: Enemy, _runtime: Dictionary) -> void:
	pass
