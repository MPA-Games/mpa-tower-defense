## ContactDamageComponent
##
## Única responsabilidad (SRP): cuando un Area3D detecta un body,
## le hace daño SI ese body sabe recibir daño.
##
## No pregunta "¿sos el Player?" ni "¿sos un CharacterBody3D?". Solo
## pregunta "¿tenés un método take_damage?" (duck typing). Esto es
## Dependency Inversion en la práctica: este componente no depende de la
## clase Player, depende de un contrato mínimo (el método take_damage).
## El día de mañana, si un barril explosivo también puede recibir daño,
## alcanza con que tenga take_damage() -- ContactDamageComponent no
## necesita cambiar una línea.
##
## Requiere un Area3D como padre (con su propio CollisionShape3D) que
## detecte capas de física de personajes (Player, otros enemigos, etc).
class_name ContactDamageComponent
extends Node

@export var damage: float = 10.0
## Si es true, hace daño una sola vez por body y no repite mientras siga
## tocando (evita "vaciar" la vida en un frame por contacto sostenido).
@export var single_hit: bool = true

var _already_hit: Array[Node] = []

func _ready() -> void:
	var area := get_parent()
	if area is Area3D:
		area.body_entered.connect(_on_body_entered)
	else:
		push_warning("ContactDamageComponent debe ser hijo de un Area3D.")


func _on_body_entered(body: Node) -> void:
	if single_hit and body in _already_hit:
		return
	if body.has_method("take_damage"):
		body.take_damage(damage)
		_already_hit.append(body)
