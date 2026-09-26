extends CharacterBody3D
class_name Enemy
@export var speed: float = 2
@export var health: float = 10
@export var goldReward: int = 5
var path: Path3D
@export var hitBox: CollisionShape3D
@export var dropItem: Item
@export var dropChance: float = 0.3
@export var comboCatalog: ComboCatalog
var statusEffectController: StatusEffectController 
var comboController: ComboController
var distanceTraveled: float = 0.0
var isDead: bool = false


func _ready() -> void:
	statusEffectController = StatusEffectController.new()
	statusEffectController.name = "StatusEffectController"
	add_child(statusEffectController)
	
	comboController = ComboController.new()
	comboController.name = "ComboController"
	add_child(comboController)
	comboController.setup(self, statusEffectController,comboCatalog)
	comboController.combo_activated.connect(ComboFeedback.show_combo_activated)
	
	collision_layer = 2
	add_to_group("enemies")

func _physics_process(delta: float) -> void:
	var currentSpeedMultiplier := statusEffectController.get_stat_multiplier(&"move_speed")
	distanceTraveled += speed * currentSpeedMultiplier * delta
	global_position = path.to_global(path.curve.sample_baked(distanceTraveled))
	
	if(distanceTraveled >= path.curve.get_baked_length()):
		reach_end()

func takeDamage(damage: float) -> void:
	if isDead:
		return
	health -= damage
	if health <= 0:
		die()

func reach_end() -> void:
	remove_from_group("enemies")
	Game.damage_health(1)
	Game.checkVictory()
	queue_free()

func die() -> void:
	if isDead:
		return

	isDead = true

	remove_from_group("enemies")

	var goldMultiplier := statusEffectController.get_stat_multiplier(&"gold_reward")
	var finalGoldReward := roundi(goldReward * goldMultiplier)

	Game.add_gold(finalGoldReward)

	if dropItem and randf() < dropChance:
		Inventory.add_item(dropItem)

	Game.checkVictory()
	queue_free()
