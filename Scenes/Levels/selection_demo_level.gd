extends Node2D

const GULAG_SCENE := "res://Scenes/Levels/FPSDemoLevel.tscn"
const TOWER_DEFENSE_SCENE := "res://Scenes/Levels/DemoLevel.tscn"

@onready var _gulag_button: Button = $CanvasLayer/GulagButton
@onready var _tower_defense_button: Button = $CanvasLayer/TDButton

func _ready() -> void:
	_gulag_button.pressed.connect(_on_gulag_pressed)
	_tower_defense_button.pressed.connect(_on_tower_defense_pressed)


func _on_gulag_pressed() -> void:
	get_tree().change_scene_to_file(GULAG_SCENE)


func _on_tower_defense_pressed() -> void:
	get_tree().change_scene_to_file(TOWER_DEFENSE_SCENE)
