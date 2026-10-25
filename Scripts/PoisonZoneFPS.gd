class_name PoisonZoneFPS
extends AreaEffectFPS

const TICK_DAMAGE: float = 1.0
const TICK_INTERVAL: float = 1.0

var _tick_timers: Dictionary = {}

func apply_to_target(target: Node3D) -> void:
	if target == null:
		return
	_tick_timers[target] = 0.0

func remove_from_target(target: Node3D) -> void:
	if target == null:
		return
	_tick_timers.erase(target)

func _process(delta: float) -> void:
	super._process(delta)
	if _time_remaining <= 0.0:
		return
	for target in _affected_targets.keys():
		if not is_instance_valid(target):
			continue
		var timer: float = _tick_timers.get(target, 0.0)
		timer += delta
		if timer >= TICK_INTERVAL:
			var receiver := target.get_node_or_null("DamageReceiver") as DamageReceiver
			if receiver != null:
				var context := DamageContext.new(TICK_DAMAGE, effect_owner, DamageFactions.Faction.PLAYER)
				receiver.receive_damage(context)
				timer = 0.0
		_tick_timers[target] = timer
	for target in _tick_timers.keys():
		if not _affected_targets.has(target):
			_tick_timers.erase(target)
