class_name PlayerStats
extends Resource

@export_group("Movement")
@export var walk_speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var gravity_multiplier: float = 1.0

@export_group("Camera")
@export var mouse_sensitivity: float = 0.003
@export var pitch_min_deg: float = -89.0
@export var pitch_max_deg: float = 89.0

@export_group("Camera Sway")
@export var sway_intensity: float = 1.0
@export var sway_speed: float = 2.0
