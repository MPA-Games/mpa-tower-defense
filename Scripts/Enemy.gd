extends CharacterBody3D
class_name Enemy
@export var speed: float = 2
@export var health: float = 10
@export var goldReward: int = 5
var path: Path3D
@export var hitBox: CollisionShape3D
@export var dropItem: Item
@export var dropChance: float = 0.3
var distanceTraveled: float = 0.0
var speedMultiplier: float = 1.0

func _ready() -> void:
	collision_layer = 2
	add_to_group("enemies")

func _physics_process(delta: float) -> void:
	distanceTraveled += speed * speedMultiplier * delta
	global_position = path.to_global(path.curve.sample_baked(distanceTraveled))
	
	if(distanceTraveled >= path.curve.get_baked_length()):
		reach_end()

func takeDamage(damage: float) -> void:
	health -= damage
	if health <= 0:
		die()

func apply_slow(multiplier: float, duration: float) -> void:
	speedMultiplier = multiplier
	await get_tree().create_timer(duration).timeout
	if not is_instance_valid(self):
		return
	speedMultiplier = 1.0

func apply_dps(_damage: float, duration: float, tickRate: float) -> void:
	await get_tree().create_timer(duration).timeout
	await get_tree().create_timer(tickRate).timeout
	#TODO

func reach_end() -> void:
	Game.damage_health(1)
	queue_free()

func die() -> void:
	Game.add_gold(goldReward)
	if dropItem and randf() < dropChance:
		Inventory.add_item(dropItem)
	queue_free()
