class_name DamageContext
extends RefCounted

var amount: float
var source: Node
var source_faction: int

func _init(damage_amount: float, damage_source: Node, faction: int) -> void:
	amount = damage_amount
	source = damage_source
	source_faction = faction