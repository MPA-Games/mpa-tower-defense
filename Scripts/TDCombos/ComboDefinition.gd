extends Resource
class_name ComboDefinition

@export var combo_id: StringName
@export var required_items: Array[StringName] = []
@export var effect: ComboEffect

func matches(active_item_ids: Array[StringName]) -> bool:
	for required_item in required_items:
		if required_item not in active_item_ids:
			return false

	return true
