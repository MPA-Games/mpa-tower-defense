class_name HudFPS
extends CanvasLayer

@onready var _enemy_remaining_label: Label = %EnemyRemainingLabel

var _enemy_spawner: EnemySpawnerFPS

func _ready() -> void:
	await get_tree().process_frame
	_enemy_spawner = get_tree().get_first_node_in_group("enemy_spawner_fps") as EnemySpawnerFPS

	if _enemy_spawner == null:
		push_warning("HudFPS: no FPS enemy spawner was found.")
		return

	_enemy_spawner.alive_enemy_count_changed.connect(_on_alive_enemy_count_changed)
	_on_alive_enemy_count_changed(_enemy_spawner.get_alive_enemy_count())

func _on_alive_enemy_count_changed(alive_count: int) -> void:
	_enemy_remaining_label.text = "Enemy remaining: %d" % alive_count
