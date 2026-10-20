class_name DeathUIFPS
extends CanvasLayer

const MAIN_MENU_SCENE := "res://Scenes/Levels/SelectionDemoLevel.tscn"

@onready var _return_button: Button = $GulagButton

var _is_open := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_return_button.pressed.connect(_on_return_button_pressed)
	hide()


func show_death_screen() -> void:
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
		push_error("DeathUIFPS: no se pudo cargar el menú principal: %s" % error)
