@tool
class_name ResourceCardFPS
extends Button

const CARD_SIZE := Vector2(180.0, 110.0)

@export var resource_title: String = "Resource":
	set(value):
		resource_title = value
		_update_visuals()
@export_multiline var resource_description: String = "":
	set(value):
		resource_description = value
		_update_visuals()
@export var resource_icon: Texture2D:
	set(value):
		resource_icon = value
		_update_visuals()
@export_range(0, 99, 1) var resource_quantity: int = 0:
	set(value):
		resource_quantity = value
		_update_visuals()

func _ready() -> void:
	toggle_mode = true
	_update_visuals()

func configure(title: String, icon_texture: Texture2D, description: String, quantity: int) -> void:
	resource_title = title
	resource_icon = icon_texture
	resource_description = description
	resource_quantity = quantity
	_update_visuals()

func _update_visuals() -> void:
	if not is_inside_tree():
		return
	custom_minimum_size = CARD_SIZE
	text = "%s\nQuantity: %d" % [resource_title, resource_quantity]
	icon = resource_icon
	icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	tooltip_text = "%s\n\n%s\n\nAvailable quantity: %d" % [
		resource_title,
		resource_description,
		resource_quantity,
	]
