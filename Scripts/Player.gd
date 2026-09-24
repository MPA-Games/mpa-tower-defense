class_name Player
extends CharacterBody3D

@export var stats: PlayerStats

@onready var _movement: PlayerMovementComponent = $MovementComponent
@onready var _camera_controller: PlayerCameraController = $CameraController
@onready var _health: HealthComponent = $Health
@onready var _head: Node3D = $Head
@onready var _camera: Camera3D = $Head/Camera3D
@onready var _sway: CameraSway = $Head/Camera3D/Sway
@onready var _wand: WandFPS = $Head/Camera3D/WandFPS

signal died

func _ready() -> void:
	if stats == null:
		push_warning("Player: no stats assigned to player.")
		return

	_wire_movement()
	_wire_camera()
	_wire_sway()
	_wire_health()
	_wire_wand()


func _wire_movement() -> void:
	_movement.body = self
	_movement.stats = stats
	
func _wire_health() -> void:
	_health.max_health = stats.max_health
	_health.died.connect(func(): died.emit())

func _wire_camera() -> void:
	_camera_controller.yaw_target = self   # the body rotates in Y
	_camera_controller.pitch_target = _head # the head rotates in X
	_camera_controller.stats = stats


func _wire_sway() -> void:
	_sway.camera = _camera
	_sway.stats = stats

func _wire_wand() -> void:
	_wand.shooter = self
	_wand.aim_origin = _camera
