class_name EnemyCombatFPS
extends Node

@export var body: CharacterBody3D
@export var movement: EnemyMovementFPS
@export var animation_controller: EnemyAnimationControllerFPS
@export var attack_area: Area3D
@export var enemy_type: EnemyTypeFPS

var _target: Node3D
var _attacking := false
var _attack_cooldown_active := false
var _dead := false

func _ready() -> void:
	_target = get_tree().get_first_node_in_group("player") as Node3D

func configure(type: EnemyTypeFPS, owner_body: CharacterBody3D, owner_movement: EnemyMovementFPS,
		owner_animation_controller: EnemyAnimationControllerFPS, owner_attack_area: Area3D) -> void:
	enemy_type = type
	body = owner_body
	movement = owner_movement
	animation_controller = owner_animation_controller
	attack_area = owner_attack_area

func _physics_process(_delta: float) -> void:
	if _dead or _attacking or _attack_cooldown_active or body == null or enemy_type == null:
		return
	if not is_instance_valid(_target):
		_target = get_tree().get_first_node_in_group("player") as Node3D
	if _target == null:
		return

	if body.global_position.distance_to(_target.global_position) <= enemy_type.attack_range:
		_start_attack()

func _start_attack() -> void:
	if _attacking or _dead:
		return
	_attacking = true
	_attack_cooldown_active = false
	movement.set_movement_enabled(false)
	animation_controller.set_attacking(true)
	var animation_duration := animation_controller.play_attack()
	_attack_sequence(animation_duration)

func _attack_sequence(animation_duration: float) -> void:
	await get_tree().create_timer(maxf(enemy_type.attack_hit_delay, 0.0)).timeout
	if _dead:
		return
	var attack_duration := maxf(animation_duration, enemy_type.attack_hit_delay)
	await get_tree().create_timer(maxf(attack_duration - enemy_type.attack_hit_delay, 0.0)).timeout
	if _dead:
		return
	_damage_player_in_attack_area()

	_attacking = false
	movement.set_movement_enabled(true)
	animation_controller.set_attacking(false)

	var remaining_cooldown := maxf(enemy_type.attack_cooldown - attack_duration, 0.0)
	_attack_cooldown_active = true
	await get_tree().create_timer(maxf(remaining_cooldown, 0.0)).timeout
	if _dead:
		return
	_attack_cooldown_active = false

func _damage_player_in_attack_area() -> void:
	if attack_area == null:
		return
	for body_in_area in attack_area.get_overlapping_bodies():
		if _damage_player_receiver(body_in_area):
			return
	for area_in_area in attack_area.get_overlapping_areas():
		if _damage_player_receiver(area_in_area.get_parent()):
			return

func _damage_player_receiver(target: Node) -> bool:
	var receiver := target.get_node_or_null("DamageReceiver") as DamageReceiver
	if receiver == null or receiver.faction != DamageFactions.Faction.PLAYER:
		return false
	receiver.receive_damage(DamageContext.new(enemy_type.damage, body, DamageFactions.Faction.ENEMY))
	return true

func set_dead() -> void:
	_dead = true
	_attacking = false
	_attack_cooldown_active = false
	if movement != null:
		movement.set_movement_enabled(false)
	if animation_controller != null:
		animation_controller.stop()
