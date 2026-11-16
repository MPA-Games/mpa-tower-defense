class_name EnemyAnimationControllerFPS
extends Node

var _animation_player: AnimationPlayer
var _body: CharacterBody3D
var _animation_names: Dictionary = {}
var _current_animation: StringName = &""
var _missing_animations: Dictionary = {}
var _attacking := false

func configure(model: Node, body: CharacterBody3D, animation_names: Dictionary) -> void:
	_body = body
	_animation_player = model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	_animation_names = animation_names
	if _animation_player == null:
		push_warning("EnemyAnimationControllerFPS: model has no AnimationPlayer.")

func _physics_process(_delta: float) -> void:
	if _attacking or _body == null:
		return
	var horizontal_velocity := Vector2(_body.velocity.x, _body.velocity.z)
	if horizontal_velocity.length_squared() > 0.001:
		play_walk()
	else:
		stop()

func play_walk() -> void:
	var animation_name := _resolve_animation("walk")
	if animation_name.is_empty():
		return
	var animation := _animation_player.get_animation(animation_name)
	animation.loop_mode = Animation.LOOP_LINEAR
	_play(animation_name)

func play_attack() -> float:
	_attacking = true
	var animation_name := _resolve_animation("attack")
	if animation_name.is_empty():
		return 0.0
	_play(animation_name)
	return _animation_player.get_animation(animation_name).length

func stop() -> void:
	_attacking = false
	if _animation_player == null:
		return
	_animation_player.stop()
	_current_animation = &""

func set_attacking(attacking: bool) -> void:
	_attacking = attacking

func _play(animation_name: StringName) -> void:
	if _animation_player == null or _current_animation == animation_name:
		return
	_animation_player.play(animation_name)
	_current_animation = animation_name

func _resolve_animation(animation_id: String) -> StringName:
	if _animation_player == null:
		return &""

	var configured_name := str(_animation_names.get(animation_id, ""))
	if not configured_name.is_empty() and _animation_player.has_animation(configured_name):
		return StringName(configured_name)

	var requested_name := configured_name.to_lower()
	for animation_name in _animation_player.get_animation_list():
		if str(animation_name).to_lower().contains(requested_name) and not requested_name.is_empty():
			return animation_name
		if str(animation_name).to_lower().contains(animation_id.to_lower()):
			return animation_name

	if not _missing_animations.has(animation_id):
		_missing_animations[animation_id] = true
		push_warning("EnemyAnimationControllerFPS: animation '%s' was not found." % configured_name)
	return &""
