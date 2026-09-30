class_name EnemyMovementFPS
extends Node

@export var body: CharacterBody3D
@export var enemy_type: EnemyTypeFPS
## Cada cuánto tiempo recalcula el camino hacia el jugador. No hace falta
## recalcularlo todos los frames -- el jugador no se teletransporta, así
## que unas pocas veces por segundo alcanza y ahorra CPU.
@export var path_update_interval: float = 0.2

@export var nav_agent: NavigationAgent3D

var _target: Node3D
var _time_since_path_update: float = 0.0
var _avoidance_connected: bool = false

func _ready() -> void:
	_target = get_tree().get_first_node_in_group("player")

	await get_tree().physics_frame
	_update_path_target()

func _physics_process(delta: float) -> void:
	if body == null or enemy_type == null or _target == null:
		return
	if nav_agent == null:
		return
	if nav_agent.avoidance_enabled and not _avoidance_connected:
		nav_agent.velocity_computed.connect(_on_velocity_computed)
		_avoidance_connected = true

	_time_since_path_update += delta
	if _time_since_path_update >= path_update_interval:
		_time_since_path_update = 0.0
		_update_path_target()

	if nav_agent.is_navigation_finished():
		return

	var next_point: Vector3 = nav_agent.get_next_path_position()
	var direction: Vector3 = (next_point - body.global_position)
	direction.y = 0.0
	direction = direction.normalized()

	var desired_velocity := direction * enemy_type.move_speed
	if nav_agent.avoidance_enabled:
		nav_agent.velocity = desired_velocity
	else:
		_apply_velocity(desired_velocity)

func _update_path_target() -> void:
	if _target:
		nav_agent.target_position = _target.global_position

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	_apply_velocity(safe_velocity)

func _apply_velocity(new_velocity: Vector3) -> void:
	new_velocity.y = 0.0
	body.velocity = new_velocity
	if new_velocity.length() > 0.01:
		body.look_at(body.global_position + new_velocity.normalized(), Vector3.UP)
	body.move_and_slide()
