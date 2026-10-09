class_name PlayerMovementComponent
extends Node

# This script handles the player's movement, including walking, jumping, and gravity application.

signal jumped
signal landed

@export var body: CharacterBody3D
@export var stats: PlayerStats

var _was_on_floor: bool = true
var _speed_multiplier: float = 1.0

func set_speed_multiplier(value: float) -> void:
	_speed_multiplier = maxf(value, 0.0)

func _physics_process(delta: float) -> void:
	if body == null or stats == null:
		return

	_apply_gravity(delta)
	_handle_jump()
	_handle_horizontal_movement()

	body.move_and_slide()
	_emit_floor_transitions()


func _apply_gravity(delta: float) -> void:
	if not body.is_on_floor():
		var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
		body.velocity.y -= gravity * stats.gravity_multiplier * delta


func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and body.is_on_floor():
		body.velocity.y = stats.jump_velocity
		jumped.emit()


func _handle_horizontal_movement() -> void:
	var input_dir: Vector2 = Input.get_vector(
		"move_left", "move_right", "move_forward", "move_back"
	)
	var direction: Vector3 = (
		body.transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	).normalized()

	if direction.length() > 0.0:
		body.velocity.x = direction.x * _effective_walk_speed()
		body.velocity.z = direction.z * _effective_walk_speed()
	else:
		body.velocity.x = move_toward(body.velocity.x, 0.0, _effective_walk_speed())
		body.velocity.z = move_toward(body.velocity.z, 0.0, _effective_walk_speed())


func _effective_walk_speed() -> float:
	return stats.walk_speed * _speed_multiplier


func _emit_floor_transitions() -> void:
	var on_floor := body.is_on_floor()
	if on_floor and not _was_on_floor:
		landed.emit()
	_was_on_floor = on_floor
