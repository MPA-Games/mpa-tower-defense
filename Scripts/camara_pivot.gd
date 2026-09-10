extends Node3D
class_name IsometricCamara
@onready var camera_3d: Camera3D = %Camera
@export var camaraSens = 0.004
@export var cameraSpeed = 0.40
@export var MaxZoom = 30
@export var MinZoom = 20


func _input(event):
	if event.is_action_pressed("ui_cancel"): get_tree().quit()
	_cameraZoom()

func _cameraZoom():
	var zoomChange = 0
	if Input.is_action_pressed("mouse_wheel_up"):
		zoomChange -= 1
	elif Input.is_action_pressed("mouse_wheel_down"):
		zoomChange += 1
	camera_3d.size += zoomChange
	camera_3d.size = clamp(camera_3d.size,MinZoom,MaxZoom)

func _physics_process(_delta: float) -> void:
	_cameraMovement()

func _cameraMovement():
	var direction = Vector2.ZERO
	direction.y = Input.get_axis("ui_up","ui_down")
	direction.x = Input.get_axis("ui_left","ui_right")
	
	global_position += (global_basis * Vector3(direction.x,0,direction.y)).normalized() * cameraSpeed
