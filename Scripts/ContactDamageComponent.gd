class_name ContactDamageComponent
extends Node

@export var damage: float = 10.0
@export var single_hit: bool = true

var _already_hit: Array[Node] = []

func _ready() -> void:
	var area := get_parent()
	if area is Area3D:
		area.body_entered.connect(_on_body_entered)
	else:
		push_warning("ContactDamageComponent must be a son of a Area3D")


func _on_body_entered(body: Node) -> void:
	if single_hit and body in _already_hit:
		return
	if body.has_method("take_damage"):
		body.take_damage(damage)
		_already_hit.append(body)
