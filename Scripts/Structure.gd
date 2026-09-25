extends StaticBody3D

class_name Structure


@export var displayName: String = "Tower"
@export var damage: float
@export var attackRange: float
@export var placementRadius: float
@export var attackCooldown: float
@export var proyectileScene: PackedScene
@export var cost: int = 50
@export var equippedItem: Item = null
@onready var timer = $Timer

@export_category("Upgrades")

@export var maxUpgradeLevel: int = 5

@export var damageUpgradeAmount: float = 1.0
@export var rangeUpgradeAmount: float = 0.5
@export var attackCooldownUpgradeAmount: float = 0.1
@export var resourceEffectUpgradeAmount: float = 0.25

@export_category("Upgrade Costs")

@export var damageBaseCost: int = 25
@export var rangeBaseCost: int = 25
@export var attackSpeedBaseCost: int = 30
@export var resourceEffectBaseCost: int = 30

@export var upgradeCostMultiplier: float = 1.5

var damageLevel: int = 0
var rangeLevel: int = 0
var attackSpeedLevel: int = 0
var resourceEffectLevel: int = 0

var resourceEffectMultiplier: float = 1.0
var enemiesInRange: Array[Enemy] = []

func _ready() -> void:
	$Timer.wait_time = attackCooldown
	%DetectionShape.shape.radius = attackRange
	collision_layer = 4
	add_to_group("structures")

func getTarget() -> Enemy:
	if enemiesInRange.is_empty():
		return null
	var furthestEnemy: Enemy = enemiesInRange[0]
	for enemy in enemiesInRange:
		if enemy.distanceTraveled > furthestEnemy.distanceTraveled:
			furthestEnemy = enemy
	return furthestEnemy

func _physics_process(_delta: float) -> void:
	var target = getTarget()
	if target:
		var lookPos = target.global_position
		lookPos.y = global_position.y
		look_at(lookPos, Vector3.UP)

func _on_detection_shape_body_entered(body: Node3D) -> void:
	if body is Enemy:
		enemiesInRange.append(body)


func _on_detection_shape_body_exited(body: Node3D) -> void:
	if body is Enemy:
		enemiesInRange.erase(body)


func _on_timer_timeout() -> void:
	var target = getTarget()
	if target == null:
		return
	var projectile = proyectileScene.instantiate()
	get_tree().current_scene.add_child(projectile) 
	projectile.global_position = global_position     
	projectile.target = target
	projectile.damage = damage
	projectile.equippedItem = equippedItem

func upgrade_damage() -> bool:
	if damageLevel >= maxUpgradeLevel:
		return false

	var upgradeCost := get_damage_upgrade_cost()

	if not Game.spend_gold(upgradeCost):
		return false

	damage += damageUpgradeAmount
	damageLevel += 1

	return true

func upgrade_range() -> bool:
	if rangeLevel >= maxUpgradeLevel:
		return false

	var upgradeCost := get_range_upgrade_cost()

	if not Game.spend_gold(upgradeCost):
		return false

	attackRange += rangeUpgradeAmount
	rangeLevel += 1
	%DetectionShape.shape.radius = attackRange

	return true

func upgrade_attack_speed() -> bool:
	if attackSpeedLevel >= maxUpgradeLevel:
		return false

	var upgradeCost := get_attack_speed_upgrade_cost()

	if not Game.spend_gold(upgradeCost):
		return false

	attackCooldown = max(0.05, attackCooldown - attackCooldownUpgradeAmount)
	attackSpeedLevel += 1
	$Timer.wait_time = attackCooldown

	return true

func upgrade_resource_effect() -> bool:
	if resourceEffectLevel >= maxUpgradeLevel:
		return false

	var upgradeCost := get_resource_effect_upgrade_cost()

	if not Game.spend_gold(upgradeCost):
		return false

	resourceEffectMultiplier += resourceEffectUpgradeAmount
	resourceEffectLevel += 1

	return true

func get_total_upgrade_level() -> int:
	return damageLevel + rangeLevel + attackSpeedLevel + resourceEffectLevel

func get_damage_upgrade_cost() -> int:
	return roundi(damageBaseCost * pow(upgradeCostMultiplier, damageLevel))

func get_range_upgrade_cost() -> int:
	return roundi(rangeBaseCost * pow(upgradeCostMultiplier, rangeLevel))

func get_attack_speed_upgrade_cost() -> int:
	return roundi(attackSpeedBaseCost * pow(upgradeCostMultiplier, attackSpeedLevel))

func get_resource_effect_upgrade_cost() -> int:
	return roundi(resourceEffectBaseCost * pow(upgradeCostMultiplier, resourceEffectLevel))
