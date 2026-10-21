extends Node

const MAX_RESOURCES: int = 4
const DEFAULT_QUANTITY: int = 3

var _selected_definitions: Array[ConsumableDefinitionFPS] = []
var _quantities: Dictionary = {}

func _ready() -> void:
	for definition in _get_catalog():
		_quantities[definition.item_id] = DEFAULT_QUANTITY

func get_catalog() -> Array[ConsumableDefinitionFPS]:
	return _get_catalog()

func set_selection(definitions: Array[ConsumableDefinitionFPS]) -> bool:
	if definitions.size() != MAX_RESOURCES:
		return false
	_selected_definitions = definitions.duplicate()
	return true

func has_selection() -> bool:
	return _selected_definitions.size() == MAX_RESOURCES

func get_selection() -> Array[ConsumableDefinitionFPS]:
	return _selected_definitions.duplicate()

func get_quantity(definition: ConsumableDefinitionFPS) -> int:
	if definition == null:
		return 0
	return _quantities.get(definition.item_id, 0)

func set_quantity(definition: ConsumableDefinitionFPS, quantity: int) -> void:
	if definition == null:
		return
	_quantities[definition.item_id] = maxi(quantity, 0)

func _get_catalog() -> Array[ConsumableDefinitionFPS]:
	return [
		preload("res://Resource/ConsumablesFPS/ElectroFPS.tres"),
		preload("res://Resource/ConsumablesFPS/GreedFPS.tres"),
		preload("res://Resource/ConsumablesFPS/DpsFPS.tres"),
		preload("res://Resource/ConsumablesFPS/SlowFPS.tres"),
		preload("res://Resource/ConsumablesFPS/PoisonFPS.tres"),
	]
