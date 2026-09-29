class_name ContactDamageComponentFPS
extends Node

@export var damage: float = 10.0
@export var single_hit: bool = true
@export_enum("Neutral:0", "Player:1", "Enemy:2") var target_faction: int = DamageFactions.Faction.PLAYER

var _already_hit: Array[Node] = []
var _source: Node
var _source_faction: int = DamageFactions.Faction.NEUTRAL

func _ready() -> void:
	var area := get_parent()
	if area is Area3D:
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)
		_source = area.get_parent()
		var source_receiver := _source.get_node_or_null("DamageReceiver") as DamageReceiver
		if source_receiver != null:
			_source_faction = source_receiver.faction
	else:
		push_warning("ContactDamageComponentFPS must be a child of an Area3D")


func _on_body_entered(body: Node) -> void:
	if single_hit and body in _already_hit:
		return

	var receiver := body.get_node_or_null("DamageReceiver") as DamageReceiver
	if receiver == null or receiver.faction != target_faction:
		return

	receiver.receive_damage(DamageContext.new(damage, _source, _source_faction))
	_already_hit.append(body)

func _on_body_exited(body: Node) -> void:
	_already_hit.erase(body)
