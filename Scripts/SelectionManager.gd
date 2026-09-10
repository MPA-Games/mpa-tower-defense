extends Node3D
class_name SelectionManager

signal structure_selected(structure: Structure)

var selectedStructure: Structure = null

func _unhandled_input(event: InputEvent) -> void:
	if %BuildManager.isPlacing:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var from = %Camera.project_ray_origin(event.position)
		var to = from + %Camera.project_ray_normal(event.position) * 1000
		var query = PhysicsRayQueryParameters3D.create(from, to, 4)
		var result = get_viewport().find_world_3d().direct_space_state.intersect_ray(query)
		if result.is_empty():
			selectedStructure = null
			structure_selected.emit(null)
			return
		selectedStructure = result.collider
		structure_selected.emit(selectedStructure)

func equip_item(item: Item) -> bool:
	if selectedStructure == null:
		return false
	if not Inventory.remove_item(item):
		return false
	selectedStructure.equippedItem = item
	return true
