extends CharacterBody3D
class_name Enemy


@export_category("Archetype")
@export var archetype: EnemyArchetype

@export_category("References")
@export var hitBox: CollisionShape3D
@export var visualRoot: Node3D
@export var comboCatalog: ComboCatalog

@export_category("Drops")
@export var dropItem: Item
@export var dropChance: float = 0.3


# ---------------------------------------------------------
# RUNTIME STATS
# ---------------------------------------------------------

var speed: float = 0.0

var health: float = 0.0
var maxHealth: float = 0.0

var goldReward: int = 0


# ---------------------------------------------------------
# RUNTIME STATE
# ---------------------------------------------------------

var path: Path3D

var distanceTraveled: float = 0.0
var isDead: bool = false

var statusEffectController: StatusEffectController
var comboController: ComboController


# ---------------------------------------------------------
# READY
# ---------------------------------------------------------

func _ready() -> void:
	if archetype == null:
		push_error(
			"Enemy sin EnemyArchetype asignado: " + name
		)
		return

	apply_archetype(archetype)

	statusEffectController = StatusEffectController.new()
	statusEffectController.name = "StatusEffectController"
	add_child(statusEffectController)

	comboController = ComboController.new()
	comboController.name = "ComboController"
	add_child(comboController)

	comboController.setup(
		self,
		statusEffectController,
		comboCatalog
	)

	comboController.combo_activated.connect(
		ComboFeedback.show_combo_activated
	)

	collision_layer = 2
	add_to_group("enemies")


# ---------------------------------------------------------
# ARCHETYPE
# ---------------------------------------------------------

# Se usa cuando nace el enemigo.
# Aplica el arquetipo y empieza con vida completa.
func apply_archetype(newArchetype: EnemyArchetype) -> void:
	if newArchetype == null:
		return

	archetype = newArchetype

	speed = newArchetype.speed

	maxHealth = newArchetype.maxHealth
	health = maxHealth

	goldReward = newArchetype.goldReward

	_change_visual(newArchetype)


# Se usa para transformar un enemigo durante la partida.
# Conserva el porcentaje actual de vida.
func change_archetype(newArchetype: EnemyArchetype) -> void:
	if newArchetype == null:
		return

	if isDead:
		return

	if archetype == newArchetype:
		return

	var healthPercentage: float = 1.0

	if maxHealth > 0.0:
		healthPercentage = health / maxHealth

	healthPercentage = clamp(
		healthPercentage,
		0.0,
		1.0
	)

	archetype = newArchetype

	speed = newArchetype.speed
	maxHealth = newArchetype.maxHealth
	goldReward = newArchetype.goldReward

	health = maxHealth * healthPercentage

	_change_visual(newArchetype)


# ---------------------------------------------------------
# VISUAL
# ---------------------------------------------------------

func _change_visual(newArchetype: EnemyArchetype) -> void:
	if visualRoot == null:
		return

	if newArchetype == null:
		return

	if newArchetype.visualScene == null:
		return

	for child in visualRoot.get_children():
		child.queue_free()

	var newVisual := newArchetype.visualScene.instantiate()

	if newVisual == null:
		return

	visualRoot.add_child(newVisual)

	if newVisual is Node3D:
		newVisual.scale = newArchetype.visualScale


# ---------------------------------------------------------
# MOVEMENT
# ---------------------------------------------------------

func _physics_process(delta: float) -> void:
	if isDead:
		return

	if path == null:
		return

	var currentSpeedMultiplier := (
		statusEffectController.get_stat_multiplier(
			&"move_speed"
		)
	)

	distanceTraveled += (
		speed
		* currentSpeedMultiplier
		* delta
	)

	global_position = path.to_global(
		path.curve.sample_baked(
			distanceTraveled
		)
	)

	if distanceTraveled >= path.curve.get_baked_length():
		reach_end()


# ---------------------------------------------------------
# DAMAGE
# ---------------------------------------------------------

func takeDamage(damage: float) -> void:
	if isDead:
		return

	health -= damage

	if health <= 0.0:
		die()


# ---------------------------------------------------------
# REACH END
# ---------------------------------------------------------

func reach_end() -> void:
	if isDead:
		return

	isDead = true

	remove_from_group("enemies")

	Game.damage_health(1)
	Game.checkVictory()

	queue_free()


# ---------------------------------------------------------
# DEATH
# ---------------------------------------------------------

func die() -> void:
	if isDead:
		return

	isDead = true

	remove_from_group("enemies")

	var goldMultiplier := (
		statusEffectController.get_stat_multiplier(
			&"gold_reward"
		)
	)

	var finalGoldReward := roundi(
		goldReward * goldMultiplier
	)

	Game.add_gold(finalGoldReward)

	_try_drop_item()

	Game.checkVictory()

	queue_free()

func _try_drop_item() -> void:
	if archetype == null:
		return

	if archetype.dropPool.is_empty():
		return

	if randf() >= archetype.dropChance:
		return

	var randomIndex: int = randi_range(
		0,
		archetype.dropPool.size() - 1
	)

	var droppedItem: Item = archetype.dropPool[randomIndex]

	if droppedItem == null:
		return

	Inventory.add_item(droppedItem)
