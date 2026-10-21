class_name WinUIFPS
extends CanvasLayer

const MAIN_MENU_SCENE := "res://Scenes/Levels/SelectionDemoLevel.tscn"

@onready var _return_button: Button = $GulagButton

var _is_open := false
var _can_check_victory := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_return_button.pressed.connect(_on_return_button_pressed)
	await get_tree().process_frame
	var spawner := get_tree().get_first_node_in_group("enemy_spawner_fps") as EnemySpawnerFPS
	if spawner == null:
		push_warning("WinUIFPS: no FPS enemy spawner was found.")
		return
	if spawner.spawning_complete:
		_can_check_victory = true
	else:
		spawner.spawning_finished.connect(_on_spawning_finished)
	hide()


func _process(_delta: float) -> void:
	if _can_check_victory and not _is_open and get_tree().get_nodes_in_group("enemy_fps").is_empty():
		show_win_screen()


func _on_spawning_finished() -> void:
	_can_check_victory = true


func show_win_screen() -> void:
	if _is_open:
		return

	_is_open = true
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true


func _on_return_button_pressed() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var error := get_tree().change_scene_to_file(MAIN_MENU_SCENE)
	if error != OK:
		push_error("WinUIFPS: could not load the main menu: %s" % error)
