class_name PlayerCameraController
extends Node

# This script handles the player's camera rotation based on mouse input and enforces pitch limits.

@export var yaw_target: Node3D
@export var pitch_target: Node3D
@export var stats: PlayerStats

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and stats != null:
		_rotate_yaw(-event.relative.x * stats.mouse_sensitivity)
		_rotate_pitch(-event.relative.y * stats.mouse_sensitivity)
	elif event.is_action_pressed("ui_cancel"):
		# Toggle rápido para poder usar el mouse fuera del juego (debug/menú).
		var captured := Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
		Input.set_mouse_mode(
			Input.MOUSE_MODE_VISIBLE if captured else Input.MOUSE_MODE_CAPTURED
		)


func _rotate_yaw(amount: float) -> void:
	if yaw_target:
		yaw_target.rotate_y(amount)


func _rotate_pitch(amount: float) -> void:
	if pitch_target == null:
		return
	var new_pitch: float = pitch_target.rotation.x + amount
	new_pitch = clamp(
		new_pitch,
		deg_to_rad(stats.pitch_min_deg),
		deg_to_rad(stats.pitch_max_deg)
	)
	pitch_target.rotation.x = new_pitch
