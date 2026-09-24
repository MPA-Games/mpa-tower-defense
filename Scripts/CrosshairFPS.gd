class_name CrosshairFPS
extends Control

@export var arm_length: float = 8.0
@export var thickness: float = 2.0
@export var gap: float = 3.0 
@export var color: Color = Color.WHITE

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	
# Draw the crosshair in the center of the control
func _draw() -> void:
	var center: Vector2 = size / 2.0

	draw_line(center - Vector2(gap + arm_length, 0), center - Vector2(gap, 0), color, thickness)
	draw_line(center + Vector2(gap, 0), center + Vector2(gap + arm_length, 0), color, thickness)
	draw_line(center - Vector2(0, gap + arm_length), center - Vector2(0, gap), color, thickness)
	draw_line(center + Vector2(0, gap), center + Vector2(0, gap + arm_length), color, thickness)
