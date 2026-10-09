class_name InventoryAdapterFPS
extends Node

signal inventory_changed
signal selection_changed(selected_slot: int)

var _inventory: InventoryFPS

func configure(inventory: InventoryFPS) -> void:
	_inventory = inventory
	_inventory.inventory_changed.connect(func(): inventory_changed.emit())
	_inventory.selection_changed.connect(func(slot): selection_changed.emit(slot))
	inventory_changed.emit()
	selection_changed.emit(_inventory.get_selected_slot())

func get_selected_slot() -> int:
	return _inventory.get_selected_slot() if _inventory else 0

func get_definition(slot: int) -> ConsumableDefinitionFPS:
	return _inventory.get_definition(slot) if _inventory else null

func get_quantity(slot: int) -> int:
	return _inventory.get_quantity(slot) if _inventory else 0

func select_slot(slot: int) -> void:
	if _inventory:
		_inventory.select_slot(slot)

func cycle_selection(direction: int) -> void:
	if _inventory:
		_inventory.cycle_selection(direction)

func consume_selected() -> ConsumableDefinitionFPS:
	return _inventory.consume_selected() if _inventory else null
