extends Node
class_name ComboController

signal combo_activated(combo_id: StringName, target: Enemy)
signal combo_deactivated(combo_id: StringName, target: Enemy)

var target: Enemy
var statusEffectController: StatusEffectController
var comboCatalog: ComboCatalog

var activeCombos: Dictionary = {}


func _ready() -> void:
	set_process(false)


func setup(
	enemy: Enemy,
	controller: StatusEffectController,
	catalog: ComboCatalog
) -> void:
	target = enemy
	statusEffectController = controller
	comboCatalog = catalog

	statusEffectController.effects_changed.connect(_on_effects_changed)


func _on_effects_changed() -> void:
	if comboCatalog == null:
		return

	var activeItems := statusEffectController.get_active_item_ids()

	for combo in comboCatalog.combos:
		var isActive := combo.matches(activeItems)
		var wasActive := activeCombos.has(combo.combo_id)

		if isActive and not wasActive:
			_activate_combo(combo)

		elif not isActive and wasActive:
			_deactivate_combo(combo.combo_id)

	_update_processing_state()


func _activate_combo(combo: ComboDefinition) -> void:
	var runtime: Dictionary = {}

	activeCombos[combo.combo_id] = {
		"definition": combo,
		"runtime": runtime,
		"tick_elapsed": 0.0
	}

	if combo.effect != null:
		combo.effect.activate(target, runtime)

	print(
		"COMBO ACTIVADO: ",
		combo.combo_id,
		" | Enemy: ",
		target.get_instance_id()
	)

	combo_activated.emit(combo.combo_id, target)


func _deactivate_combo(combo_id: StringName) -> void:
	var data: Dictionary = activeCombos[combo_id]
	var combo: ComboDefinition = data["definition"]
	var runtime: Dictionary = data["runtime"]

	if combo.effect != null:
		combo.effect.deactivate(target, runtime)

	activeCombos.erase(combo_id)

	print(
		"COMBO DESACTIVADO: ",
		combo_id,
		" | Enemy: ",
		target.get_instance_id()
	)

	combo_deactivated.emit(combo_id, target)


func _process(delta: float) -> void:
	for combo_id in activeCombos:
		var data: Dictionary = activeCombos[combo_id]
		var combo: ComboDefinition = data["definition"]

		if combo.effect == null:
			continue

		if combo.effect.tickInterval <= 0.0:
			continue

		data["tick_elapsed"] += delta

		while data["tick_elapsed"] >= combo.effect.tickInterval:
			data["tick_elapsed"] -= combo.effect.tickInterval
			combo.effect.tick(target, data["runtime"])


func _update_processing_state() -> void:
	var needsProcessing := false

	for data in activeCombos.values():
		var combo: ComboDefinition = data["definition"]

		if combo.effect != null and combo.effect.tickInterval > 0.0:
			needsProcessing = true
			break

	set_process(needsProcessing)
