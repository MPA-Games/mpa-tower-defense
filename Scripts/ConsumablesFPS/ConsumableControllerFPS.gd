class_name ConsumableControllerFPS
extends Node

@export var inventory: InventoryAdapterFPS
@export var effects: EffectControllerFPS

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fps_consume"):
		_consume_selected()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("fps_slot_1"):
		_select_slot(0)
	elif event.is_action_pressed("fps_slot_2"):
		_select_slot(1)
	elif event.is_action_pressed("fps_slot_3"):
		_select_slot(2)
	elif event.is_action_pressed("fps_slot_4"):
		_select_slot(3)
	elif event.is_action_pressed("fps_next_slot"):
		inventory.cycle_selection(1)
	elif event.is_action_pressed("fps_previous_slot"):
		inventory.cycle_selection(-1)
	else:
		return
	get_viewport().set_input_as_handled()

func _select_slot(slot: int) -> void:
	inventory.select_slot(slot)

func _consume_selected() -> void:
	var selected_slot := inventory.get_selected_slot()
	var definition := inventory.consume_selected()
	if definition:
		effects.apply_consumable(definition, selected_slot)
