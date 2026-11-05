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
	# La duración mecánica del StatusEffect no determina
	# cuánto tiempo sirve como ingrediente de combo.
	# Eso lo controla combo_time_left.
	_update_processing_state()


func _on_effect_applied(
	effect_id: StringName,
	source_item_id: StringName,
	context: EffectContext,
	revision: int
) -> void:
	# Efectos internos como virus_stun no llevan EffectContext
	# y por lo tanto no participan del sistema de combos.
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

	if lockedIngredients.has(source_item_id):
		# Una nueva aplicación queda pendiente para cuando
		# el combo actual libere este tipo de ingrediente.
		if pendingIngredients.has(source_item_id):
			var currentPending: Dictionary = pendingIngredients[source_item_id]

			# Conserva el orden de la primera aplicación pendiente.
			ingredient["application_order"] = currentPending["application_order"]

		pendingIngredients[source_item_id] = ingredient

		_update_processing_state()
		return

	# -----------------------------------------------------
	# INGREDIENTE DISPONIBLE
	# -----------------------------------------------------

	if availableIngredients.has(source_item_id):
		var currentAvailable: Dictionary = availableIngredients[source_item_id]

		# Refrescar un efecto no modifica su lugar en FIFO.
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

		# Ingredientes más antiguos primero.
		itemIds.sort_custom(
			func(a, b):
				return (
					availableIngredients[a]["application_order"]
					<
					availableIngredients[b]["application_order"]
				)
		)

		var comboActivated := false

		for i in range(itemIds.size()):
			var firstItem: StringName = itemIds[i]

			for j in range(i + 1, itemIds.size()):
				var secondItem: StringName = itemIds[j]

				var combo := _find_combo_for_pair(
					firstItem,
					secondItem
				)

				if combo == null:
					continue

				# CRÍTICO:
				# solo consideramos resuelto el combo si
				# efectivamente pudo activarse.
				if _activate_combo(combo):
					comboActivated = true
					break

			if comboActivated:
				break

		# Si ninguna pareja pudo activarse, debemos salir.
		# De lo contrario entraríamos en un while infinito.
		if not comboActivated:
			break


func _find_combo_for_pair(
	firstItem: StringName,
	secondItem: StringName
) -> ComboDefinition:
	if comboCatalog == null:
		return null

	for combo: ComboDefinition in comboCatalog.combos:
		if combo == null:
			continue

		if combo.required_items.size() != 2:
			continue

		# Si este mismo combo ya está ejecutándose,
		# no puede volver a activarse simultáneamente.
		if activeCombos.has(combo.combo_id):
			continue

		var matchesPair := (
			firstItem in combo.required_items
			and secondItem in combo.required_items
		)

		if not matchesPair:
			continue

		# Algunos efectos pueden tener condiciones especiales.
		# Ejemplo: Electro + Greed no transforma nuevamente
		# a un enemigo que ya posee el arquetipo destino.
		if combo.effect != null:
			if not combo.effect.can_activate(target):
				continue

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
) -> bool:
	if combo == null:
		return false

	# No activamos el mismo combo dos veces simultáneamente.
	if activeCombos.has(combo.combo_id):
		return false

	# Segunda validación de seguridad.
	# Aunque normalmente ya se chequeó en _find_combo_for_pair(),
	# esto evita depender de quién llame a _activate_combo().
	if combo.effect != null:
		if not combo.effect.can_activate(target):
			return false

	# Todos los ingredientes deben seguir disponibles.
	for itemId: StringName in combo.required_items:
		if not availableIngredients.has(itemId):
			return false

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
	# CREAR CONTEXTO
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
	# EJECUTAR
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

	# duration <= 0 significa combo instantáneo.
	if combo.duration <= 0.0:
		call_deferred(
			"_deactivate_combo",
			combo.combo_id
		)

	return true


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

		# El ingrediente tiene que pertenecer
		# específicamente a este combo.
		if lockData["combo_id"] != combo_id:
			continue

		var ingredient: Dictionary = lockData["ingredient"]

		var effectId: StringName = ingredient["effect_id"]
		var revision: int = ingredient["revision"]

		# Consume solamente la revisión original.
		# Si recibió una aplicación posterior,
		# esa revisión nueva permanece viva.
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

	# Al liberar ingredientes puede haber otro combo listo.
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
	# Ventanas temporales de AVAILABLE y PENDING.
	_update_ingredient_timers(delta)

	# Copiamos las keys porque un combo puede borrarse
	# durante esta misma iteración.
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

				# El tick podría matar al enemigo.
				if not is_instance_valid(target):
					return

				if target.isDead:
					return

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

	# Ingredientes esperando necesitan actualizar su timer.
	if not availableIngredients.is_empty():
		needsProcessing = true

	if not pendingIngredients.is_empty():
		needsProcessing = true

	# Combos persistentes necesitan duración/ticks.
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
