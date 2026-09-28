extends Node
class_name ComboController

signal combo_activated(combo_id: StringName, target: Enemy)
signal combo_deactivated(combo_id: StringName, target: Enemy)

var target: Enemy
var statusEffectController: StatusEffectController
var comboCatalog: ComboCatalog

# Ingredientes libres para formar combos.
var availableIngredients: Dictionary = {}

# Ingredientes actualmente usados por combos.
var lockedIngredients: Dictionary = {}

# Nuevas aplicaciones recibidas mientras
# ese tipo de ingrediente estaba bloqueado.
var pendingIngredients: Dictionary = {}

# Combos actualmente ejecutándose.
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
	statusEffectController.effect_applied.connect(_on_effect_applied)


# ---------------------------------------------------------
# STATUS EFFECT EVENTS
# ---------------------------------------------------------

func _on_effects_changed() -> void:
	# La duración del efecto mecánico ya no controla
	# cuánto tiempo el ingrediente sirve para un combo.
	#
	# Eso ahora lo controla combo_time_left.
	_update_processing_state()


func _on_effect_applied(
	effect_id: StringName,
	source_item_id: StringName,
	context: EffectContext,
	revision: int
) -> void:
	if context == null:
		return

	var ingredient := {
		"effect_id": effect_id,
		"item_id": source_item_id,
		"context": context,
		"revision": revision,
		"application_order": context.applicationOrder,
		"combo_time_left": context.comboWindowDuration
	}

	# -----------------------------------------------------
	# INGREDIENTE BLOQUEADO
	# -----------------------------------------------------
	# Si este recurso ya está participando de un combo,
	# esta nueva aplicación queda esperando.
	if lockedIngredients.has(source_item_id):

		if pendingIngredients.has(source_item_id):
			var currentPending: Dictionary = pendingIngredients[source_item_id]

			# Conserva el orden de la PRIMERA aplicación pendiente.
			# Los siguientes impactos solamente refrescan sus datos.
			ingredient["application_order"] = currentPending["application_order"]

		pendingIngredients[source_item_id] = ingredient

		_update_processing_state()
		return

	# -----------------------------------------------------
	# INGREDIENTE DISPONIBLE
	# -----------------------------------------------------
	# Si ya estaba esperando libre, conserva su posición FIFO.
	if availableIngredients.has(source_item_id):
		var currentAvailable: Dictionary = availableIngredients[source_item_id]

		ingredient["application_order"] = currentAvailable["application_order"]

	availableIngredients[source_item_id] = ingredient

	_resolve_available_combos()
	_update_processing_state()


# ---------------------------------------------------------
# FIFO COMBO RESOLUTION
# ---------------------------------------------------------

func _resolve_available_combos() -> void:
	if comboCatalog == null:
		return

	while availableIngredients.size() >= 2:
		var itemIds: Array = availableIngredients.keys()

		# Más antiguo primero.
		itemIds.sort_custom(
			func(a, b):
				return (
					availableIngredients[a]["application_order"]
					<
					availableIngredients[b]["application_order"]
				)
		)

		var comboFound := false

		for i in range(itemIds.size()):
			var firstItem: StringName = itemIds[i]

			for j in range(i + 1, itemIds.size()):
				var secondItem: StringName = itemIds[j]

				var combo := _find_combo_for_pair(
					firstItem,
					secondItem
				)

				if combo != null:
					_activate_combo(combo)

					comboFound = true
					break

			if comboFound:
				break

		if not comboFound:
			break


func _find_combo_for_pair(
	firstItem: StringName,
	secondItem: StringName
) -> ComboDefinition:

	for combo: ComboDefinition in comboCatalog.combos:

		if combo.required_items.size() != 2:
			continue

		if (
			firstItem in combo.required_items
			and secondItem in combo.required_items
		):
			return combo

	return null


# ---------------------------------------------------------
# COMBO CONTEXT
# ---------------------------------------------------------

func _build_combo_context(
	combo: ComboDefinition
) -> ComboContext:

	var comboContext := ComboContext.new()

	var totalPower: float = 0.0
	var ingredientCount: int = 0

	for itemId: StringName in combo.required_items:

		if not lockedIngredients.has(itemId):
			continue

		var lockData: Dictionary = lockedIngredients[itemId]
		var ingredient: Dictionary = lockData["ingredient"]

		var context: EffectContext = ingredient["context"]
		var revision: int = ingredient["revision"]

		comboContext.ingredientContexts[itemId] = context
		comboContext.ingredientRevisions[itemId] = revision

		if context != null:
			totalPower += context.effectMultiplier
			ingredientCount += 1

	if ingredientCount > 0:
		comboContext.powerMultiplier = (
			totalPower / ingredientCount
		)

	return comboContext


# ---------------------------------------------------------
# ACTIVATE COMBO
# ---------------------------------------------------------

func _activate_combo(
	combo: ComboDefinition
) -> void:

	# No activamos dos veces exactamente el mismo combo
	# simultáneamente sobre el mismo enemigo.
	if activeCombos.has(combo.combo_id):
		return

	# Verificamos que sus ingredientes sigan disponibles.
	for itemId: StringName in combo.required_items:
		if not availableIngredients.has(itemId):
			return

	# -----------------------------------------------------
	# AVAILABLE → LOCKED
	# -----------------------------------------------------

	for itemId: StringName in combo.required_items:
		var ingredient: Dictionary = availableIngredients[itemId]

		lockedIngredients[itemId] = {
			"combo_id": combo.combo_id,
			"ingredient": ingredient
		}

		availableIngredients.erase(itemId)

	# -----------------------------------------------------
	# CREAR CONTEXTO DEL COMBO
	# -----------------------------------------------------

	var comboContext := _build_combo_context(combo)

	var runtime: Dictionary = {
		"combo_context": comboContext
	}

	activeCombos[combo.combo_id] = {
		"definition": combo,
		"runtime": runtime,
		"tick_elapsed": 0.0,
		"time_left": combo.duration
	}

	# -----------------------------------------------------
	# EJECUTAR EFECTO
	# -----------------------------------------------------

	if combo.effect != null:
		combo.effect.activate(
			target,
			runtime
		)


	combo_activated.emit(
		combo.combo_id,
		target
	)

	_update_processing_state()

	# duration = 0 significa combo instantáneo.
	#
	# Ejemplo:
	# DPS + Electro → explosión → termina.
	if combo.duration <= 0.0:
		call_deferred(
			"_deactivate_combo",
			combo.combo_id
		)


# ---------------------------------------------------------
# DEACTIVATE COMBO
# ---------------------------------------------------------

func _deactivate_combo(
	combo_id: StringName
) -> void:

	if not activeCombos.has(combo_id):
		return

	var data: Dictionary = activeCombos[combo_id]
	var combo: ComboDefinition = data["definition"]
	var runtime: Dictionary = data["runtime"]

	if combo.effect != null:
		combo.effect.deactivate(
			target,
			runtime
		)

	# -----------------------------------------------------
	# LIBERAR / CONSUMIR INGREDIENTES
	# -----------------------------------------------------

	for itemId: StringName in combo.required_items:

		if not lockedIngredients.has(itemId):
			continue

		var lockData: Dictionary = lockedIngredients[itemId]

		# Seguridad: ese ingrediente tiene que pertenecer
		# al combo que estamos terminando.
		if lockData["combo_id"] != combo_id:
			continue

		var ingredient: Dictionary = lockData["ingredient"]

		var effectId: StringName = ingredient["effect_id"]
		var revision: int = ingredient["revision"]

		# Consume solamente el efecto ORIGINAL
		# que participó del combo.
		#
		# Si hubo una aplicación posterior y la revision cambió,
		# StatusEffectController no la elimina.
		statusEffectController.remove_effect_if_revision(
			effectId,
			revision
		)

		lockedIngredients.erase(itemId)

		# -------------------------------------------------
		# PENDING → AVAILABLE
		# -------------------------------------------------

		if pendingIngredients.has(itemId):
			availableIngredients[itemId] = pendingIngredients[itemId]
			pendingIngredients.erase(itemId)

	activeCombos.erase(combo_id)


	combo_deactivated.emit(
		combo_id,
		target
	)

	# Al liberar ingredientes pueden aparecer
	# nuevos combos inmediatamente.
	_resolve_available_combos()

	_update_processing_state()


# ---------------------------------------------------------
# INGREDIENT COMBO WINDOWS
# ---------------------------------------------------------

func _update_ingredient_timers(
	delta: float
) -> void:

	# -----------------------------------------------------
	# AVAILABLE
	# -----------------------------------------------------

	for itemId in availableIngredients.keys():

		var ingredient: Dictionary = availableIngredients[itemId]

		ingredient["combo_time_left"] -= delta

		if ingredient["combo_time_left"] <= 0.0:

			availableIngredients.erase(itemId)

	# -----------------------------------------------------
	# PENDING
	# -----------------------------------------------------

	for itemId in pendingIngredients.keys():

		var ingredient: Dictionary = pendingIngredients[itemId]

		ingredient["combo_time_left"] -= delta

		if ingredient["combo_time_left"] <= 0.0:


			pendingIngredients.erase(itemId)


# ---------------------------------------------------------
# PROCESS
# ---------------------------------------------------------

func _process(
	delta: float
) -> void:

	# Ventanas temporales de los ingredientes.
	_update_ingredient_timers(delta)

	# Copiamos las keys porque durante el loop
	# podemos desactivar y borrar combos.
	var comboIds: Array = activeCombos.keys()

	for combo_id in comboIds:

		if not activeCombos.has(combo_id):
			continue

		var data: Dictionary = activeCombos[combo_id]
		var combo: ComboDefinition = data["definition"]

		# -------------------------------------------------
		# TICKS DEL COMBO
		# -------------------------------------------------

		if (
			combo.effect != null
			and combo.effect.tickInterval > 0.0
		):
			data["tick_elapsed"] += delta

			while (
				data["tick_elapsed"]
				>= combo.effect.tickInterval
			):
				data["tick_elapsed"] -= combo.effect.tickInterval

				combo.effect.tick(
					target,
					data["runtime"]
				)

		# -------------------------------------------------
		# DURACIÓN DEL COMBO
		# -------------------------------------------------

		if combo.duration > 0.0:

			data["time_left"] -= delta

			if data["time_left"] <= 0.0:
				_deactivate_combo(combo_id)

	_update_processing_state()


# ---------------------------------------------------------
# PROCESS SLEEP / WAKE
# ---------------------------------------------------------

func _update_processing_state() -> void:

	var needsProcessing := false

	# Ingredientes esperando necesitan timer.
	if not availableIngredients.is_empty():
		needsProcessing = true

	if not pendingIngredients.is_empty():
		needsProcessing = true

	# Combos persistentes pueden necesitar duración o ticks.
	if not needsProcessing:

		for data in activeCombos.values():

			var combo: ComboDefinition = data["definition"]

			if combo.duration > 0.0:
				needsProcessing = true
				break

			if (
				combo.effect != null
				and combo.effect.tickInterval > 0.0
			):
				needsProcessing = true
				break

	set_process(needsProcessing)
