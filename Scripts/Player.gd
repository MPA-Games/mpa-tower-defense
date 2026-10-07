class_name Player
extends CharacterBody3D

@export var stats: PlayerStats

@onready var _movement: PlayerMovementComponent = $MovementComponent
@onready var _camera_controller: PlayerCameraController = $CameraController
@onready var _health: HealthComponentFPS = $Health
@onready var _head: Node3D = $Head
@onready var _camera: Camera3D = $Head/Camera3D
@onready var _sway: CameraSway = $Head/Camera3D/Sway
@onready var _wand: WandFPS = $Head/Camera3D/WandFPS
@onready var _inventory: InventoryFPS = $InventoryFPS
@onready var _inventory_adapter: InventoryAdapterFPS = $InventoryAdapterFPS
@onready var _effects: EffectControllerFPS = $EffectControllerFPS
@onready var _consumables: ConsumableControllerFPS = $ConsumableControllerFPS
@onready var _attack_modifiers: AttackModifiersFPS = $AttackModifiersFPS
@onready var _hotbar: HotbarFPS = $Head/Camera3D/Hudfps_tscn/HotbarFPS
@onready var _attached_objects: Node3D = $AttachedObjectsFPS

signal died

func _ready() -> void:
	add_to_group("player")
	if stats == null:
		push_warning("Player: no stats assigned to player.")
		return

	_wire_movement()
	_wire_camera()
	_wire_sway()
	_wire_health()
	_wire_wand()
	_wire_consumables()


func _wire_movement() -> void:
	_movement.body = self
	_movement.stats = stats
	
func _wire_health() -> void:
	_health.configure(stats.max_health)
	_health.died.connect(func(): died.emit())

func _wire_camera() -> void:
	_camera_controller.yaw_target = self   # the body rotates in Y
	_camera_controller.pitch_target = _head # the head rotates in X
	_camera_controller.stats = stats


func _wire_sway() -> void:
	_sway.camera = _camera
	_sway.stats = stats
	_sway.configure(_camera, stats)

func _wire_wand() -> void:
	_wand.shooter = self
	_wand.aim_origin = _camera


func _wire_consumables() -> void:
	_inventory_adapter.configure(_inventory)
	_effects.movement = _movement
	_effects.sway = _sway
	_effects.effect_owner = self
	_effects.attached_objects = _attached_objects
	_effects.configure_attack_modifiers(_attack_modifiers)
	_consumables.inventory = _inventory_adapter
	_consumables.effects = _effects
	_hotbar.configure(_inventory_adapter, _effects)
	_wand.attack_modifiers = _attack_modifiers
