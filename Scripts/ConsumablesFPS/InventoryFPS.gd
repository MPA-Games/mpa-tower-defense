class_name InventoryFPS
extends Node

const MAX_SLOTS: int = 4

signal inventory_changed
signal selection_changed(selected_slot: int)

@export var starting_definitions: Array[ConsumableDefinitionFPS] = []
@export_range(0, 99, 1) var starting_quantity: int = 3

var _definitions: Array[ConsumableDefinitionFPS] = []
var _quantities: Array[int] = []
var _selected_slot: int = 0

func _ready() -> void:
	_initialize_slots()

func _initialize_slots() -> void:
	if not _validate_starting_definitions():
		return
	_definitions.clear()
	_quantities.clear()
	for slot in MAX_SLOTS:
		_definitions.append(starting_definitions[slot])
		_quantities.append(starting_quantity)
	inventory_changed.emit()
	selection_changed.emit(_selected_slot)

func _validate_starting_definitions() -> bool:
	if starting_definitions.size() != MAX_SLOTS:
		push_error(
			"InventoryFPS: se requieren exactamente %d consumibles iniciales." % MAX_SLOTS
		)
		return false

	var used_ids: Dictionary[StringName, bool] = {}
	for definition in starting_definitions:
		if definition == null:
			push_error("InventoryFPS: no puede haber slots iniciales vacios.")
			return false
		if used_ids.has(definition.item_id):
			push_error(
				"InventoryFPS: el consumible '%s' esta repetido." % definition.item_id
			)
			return false
		used_ids[definition.item_id] = true
	return true

func get_selected_slot() -> int:
	return _selected_slot

func get_definition(slot: int) -> ConsumableDefinitionFPS:
	if not _is_valid_slot(slot):
		return null
	return _definitions[slot]

func get_quantity(slot: int) -> int:
	if not _is_valid_slot(slot):
		return 0
	return _quantities[slot]

func select_slot(slot: int) -> void:
	if not _is_valid_slot(slot) or slot == _selected_slot:
		return
	_selected_slot = slot
	selection_changed.emit(_selected_slot)

func cycle_selection(direction: int) -> void:
	if direction == 0:
		return
	select_slot(posmod(_selected_slot + signi(direction), MAX_SLOTS))

func consume_selected() -> ConsumableDefinitionFPS:
	var definition := get_definition(_selected_slot)
	if definition == null or _quantities[_selected_slot] <= 0:
		return null
	_quantities[_selected_slot] -= 1
	inventory_changed.emit()
	return definition

func _is_valid_slot(slot: int) -> bool:
	return slot >= 0 and slot < MAX_SLOTS
