class_name EnemyFPS
extends CharacterBody3D

@export var enemy_type: EnemyTypeFPS
@export var death_vfx_spawn: Node3D
@export var enable_death_vfx: bool = false

@onready var _movement: EnemyMovementFPS = $Movement
@onready var _health: HealthComponentFPS = $Health
@onready var _contact_damage: ContactDamageComponentFPS = $HurtBox/ContactDamage
@onready var _body_hitbox: CollisionShape3D = $BodyHitboxFPS
@onready var _head_hitbox: CollisionShape3D = $HeadHitboxFPS

func _ready() -> void:
	add_to_group("enemy_fps")
	_movement.nav_agent = $NavAgent

	if enemy_type == null:
		push_warning("EnemyFPS: falta asignar un EnemyTypeFPS (lo hace el EnemySpawnerFPS).")
		return

	_movement.body = self
	_movement.enemy_type = enemy_type
	_spawn_model()
	_configure_hitboxes()

	_health.configure(enemy_type.max_health)
	_health.died.connect(_on_died)

	_contact_damage.damage = enemy_type.damage

func _spawn_model() -> void:
	if enemy_type.model_scene == null:
		push_warning("EnemyFPS: el tipo %s no tiene model_scene asignado." % enemy_type.display_name)
		return

	var model := enemy_type.model_scene.instantiate() as Node3D
	if model == null:
		push_warning("EnemyFPS: model_scene de %s no instancia un Node3D." % enemy_type.display_name)
		return

	model.name = "Model"
	model.scale = enemy_type.model_scale
	model.rotation_degrees = enemy_type.model_rotation_degrees
	add_child(model)

func _configure_hitboxes() -> void:
	if enemy_type.body_hitbox_shape != null:
		_body_hitbox.shape = enemy_type.body_hitbox_shape
	_body_hitbox.position = enemy_type.body_hitbox_position
	_body_hitbox.rotation_degrees = enemy_type.body_hitbox_rotation_degrees

	if enemy_type.head_hitbox_shape != null:
		_head_hitbox.shape = enemy_type.head_hitbox_shape
	_head_hitbox.position = enemy_type.head_hitbox_position
	_head_hitbox.rotation_degrees = enemy_type.head_hitbox_rotation_degrees

func take_damage(amount: float) -> void:
	_health.take_damage(amount)

func is_head_shape(shape_index: int) -> bool:
	if _head_hitbox == null:
		return false
	var owner_id := shape_find_owner(shape_index)
	return shape_owner_get_owner(owner_id) == _head_hitbox

func _on_died() -> void:
	_spawn_death_vfx()
	queue_free()	

func _spawn_death_vfx() -> void:
	if not enable_death_vfx or enemy_type == null or enemy_type.death_vfx_scene == null:
		return

	var vfx := enemy_type.death_vfx_scene.instantiate() as Node3D
	if vfx == null:
		push_warning("EnemyFPS: el death_vfx_scene de %s no instancia un Node3D." % enemy_type.display_name)
		return

	get_tree().current_scene.add_child(vfx)
	var spawn_transform := global_transform
	if death_vfx_spawn != null:
		spawn_transform = death_vfx_spawn.global_transform
	vfx.global_transform = spawn_transform
