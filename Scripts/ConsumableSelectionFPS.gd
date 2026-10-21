extends Control

const FPS_SCENE := "res://Scenes/Levels/FPSDemoLevel.tscn"
const RESOURCE_CARD_SCENE := preload("res://Scenes/UI/FPS/ResourceCardFPS.tscn")

@onready var _resources_grid: GridContainer = %ResourcesGrid
@onready var _selected_label: Label = %SelectedLabel
@onready var _confirm_button: Button = %ConfirmButton

var _selected_definitions: Array[ConsumableDefinitionFPS] = []
var _buttons: Dictionary = {}

func _ready() -> void:
	_confirm_button.pressed.connect(_confirm_selection)
	_build_resource_cards()
	_refresh_selection()

func _build_resource_cards() -> void:
	for definition in FPSLoadout.get_catalog():
		var card := RESOURCE_CARD_SCENE.instantiate() as ResourceCardFPS
		if card == null:
			push_error("ConsumableSelectionFPS: resource card scene is invalid.")
			continue
		card.configure(
			definition.display_name,
			definition.icon,
			definition.description,
			FPSLoadout.get_quantity(definition),
		)
		card.pressed.connect(func(): _toggle_definition(definition))
		_resources_grid.add_child(card)
		_buttons[definition] = card

func _toggle_definition(definition: ConsumableDefinitionFPS) -> void:
	if _selected_definitions.has(definition):
		_selected_definitions.erase(definition)
	elif _selected_definitions.size() < FPSLoadout.MAX_RESOURCES:
		_selected_definitions.append(definition)
	_refresh_selection()

func _refresh_selection() -> void:
	_selected_label.text = "Selected booze: %d / %d" % [
		_selected_definitions.size(),
		FPSLoadout.MAX_RESOURCES,
	]
	_confirm_button.disabled = _selected_definitions.size() != FPSLoadout.MAX_RESOURCES
	for definition in _buttons:
		var button: Button = _buttons[definition]
		button.button_pressed = _selected_definitions.has(definition)
		button.disabled = (
			_selected_definitions.size() == FPSLoadout.MAX_RESOURCES
			and not _selected_definitions.has(definition)
		)

func _confirm_selection() -> void:
	if not FPSLoadout.set_selection(_selected_definitions):
		return
	var error := get_tree().change_scene_to_file(FPS_SCENE)
	if error != OK:
		push_error("ConsumableSelectionFPS: could not load FPS scene: %s" % error)
