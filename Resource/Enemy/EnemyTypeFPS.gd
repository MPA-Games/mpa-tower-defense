class_name EnemyTypeFPS
extends Resource

@export var display_name: String = "Enemy"
@export_category("Model")
@export var model_scene: PackedScene
@export var model_scale: Vector3 = Vector3.ONE
@export var model_rotation_degrees: Vector3 = Vector3.ZERO
@export_category("Hitboxes")
@export var body_hitbox_shape: Shape3D
@export var body_hitbox_position: Vector3 = Vector3.ZERO
@export var body_hitbox_rotation_degrees: Vector3 = Vector3.ZERO
@export var head_hitbox_shape: Shape3D
@export var head_hitbox_position: Vector3 = Vector3.ZERO
@export var head_hitbox_rotation_degrees: Vector3 = Vector3.ZERO
@export_category("Stats")
@export var max_health: float = 30.0
@export var damage: float = 10.0
@export var move_speed: float = 3.0
