class_name CrosshairFPS
extends Control

@export var color: Color = Color.WHITE
@export var dot_radius: float = 2.0
@export_category("Hitmarker")
@export var hitmarker_length: float = 8.0
@export var hitmarker_gap: float = 6.0
@export var hitmarker_thickness: float = 1.0
@export var hitmarker_duration: float = 0.25
@export var critical_hitmarker_length: float = 8.0
@export var critical_hitmarker_gap: float = 3.0
@export var critical_hitmarker_line_offset: float = 1.5

var _hitmarker_time_remaining: float = 0.0
var _hitmarker_is_critical: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	add_to_group("crosshair_fps")

func _process(delta: float) -> void:
	if _hitmarker_time_remaining <= 0.0:
		return
	_hitmarker_time_remaining = maxf(_hitmarker_time_remaining - delta, 0.0)
	queue_redraw()

func show_hitmarker(is_critical: bool = false) -> void:
	_hitmarker_time_remaining = hitmarker_duration
	_hitmarker_is_critical = is_critical
	queue_redraw()
	
# Draw the crosshair in the center of the control
func _draw() -> void:
	var center: Vector2 = size / 2.0

	draw_circle(center, dot_radius, color)

	if _hitmarker_time_remaining <= 0.0:
		return

	var hitmarker_color := Color.WHITE
	if _hitmarker_is_critical:
		_draw_hitmarker(center, critical_hitmarker_gap, critical_hitmarker_length, hitmarker_color, true)
	else:
		_draw_hitmarker(center, hitmarker_gap, hitmarker_length, hitmarker_color)

func _draw_hitmarker(
	center: Vector2,
	gap_distance: float,
	arm_length: float,
	hitmarker_color: Color,
	double_lines: bool = false,
) -> void:
	var diagonal := Vector2.ONE.normalized()
	_draw_hitmarker_arm(center, diagonal, gap_distance, arm_length, hitmarker_color, double_lines)
	_draw_hitmarker_arm(center, Vector2(-1, 1).normalized(), gap_distance, arm_length, hitmarker_color, double_lines)
	_draw_hitmarker_arm(center, Vector2(1, -1).normalized(), gap_distance, arm_length, hitmarker_color, double_lines)
	_draw_hitmarker_arm(center, -diagonal, gap_distance, arm_length, hitmarker_color, double_lines)

func _draw_hitmarker_arm(
	center: Vector2,
	direction: Vector2,
	gap_distance: float,
	arm_length: float,
	hitmarker_color: Color,
 	double_lines: bool,
) -> void:
	var start := center + direction * gap_distance
	var end := center + direction * (gap_distance + arm_length)
	if double_lines:
		var perpendicular := Vector2(-direction.y, direction.x) * critical_hitmarker_line_offset
		draw_line(start + perpendicular, end + perpendicular, hitmarker_color, hitmarker_thickness, true)
		draw_line(start - perpendicular, end - perpendicular, hitmarker_color, hitmarker_thickness, true)
	else:
		draw_line(start, end, hitmarker_color, hitmarker_thickness, true)
