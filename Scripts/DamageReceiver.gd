class_name DamageReceiver
extends Node

@export_enum("Neutral:0", "Player:1", "Enemy:2") var faction: int = DamageFactions.Faction.NEUTRAL
@export var health_path: NodePath = NodePath("../Health")

var _health: HealthComponentFPS

func _ready() -> void:
	_health = get_node_or_null(health_path) as HealthComponentFPS
	if _health == null:
		push_warning("DamageReceiver: no se encontró HealthComponentFPS en %s." % health_path)

func receive_damage(context: DamageContext) -> void:
	if context == null or _health == null or context.amount <= 0.0:
		return
	if context.source_faction == faction and faction != DamageFactions.Faction.NEUTRAL:
		return
	_health.take_damage(context.amount)
