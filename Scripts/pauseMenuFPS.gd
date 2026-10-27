class_name PauseMenuFPS
extends CanvasLayer

const MAIN_MENU_SCENE := "res://Scenes/Levels/SelectionDemoLevel.tscn"

@onready var _resume_button: Button = $VBoxContainer/ResumeButton
@onready var _return_to_menu_button: Button = $VBoxContainer/ReturnToMenuButton

var _is_open := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_resume_button.pressed.connect(_on_resume_button_pressed)
	_return_to_menu_button.pressed.connect(_on_return_to_menu_button_pressed)
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause"):
		return
	if event is InputEventKey and event.echo:
		return

	if _is_open:
		_resume_game()
	elif not get_tree().paused:
		_open()

	get_viewport().set_input_as_handled()


func _open() -> void:
	_is_open = true
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true


func _on_resume_button_pressed() -> void:
	_resume_game()


func _resume_game() -> void:
	_is_open = false
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false


func _on_return_to_menu_button_pressed() -> void:
	_is_open = false
	visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var error := get_tree().change_scene_to_file(MAIN_MENU_SCENE)
	if error != OK:
		push_error("PauseMenuFPS: could not load the main menu: %s" % error)
