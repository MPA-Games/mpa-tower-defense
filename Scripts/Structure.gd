extends StaticBody3D

class_name Structure

@export var damage: float
@export var attackRange: float
@export var placementRadius: float
@export var attackCooldown: float
@export var proyectileScene: PackedScene
@export var cost: int = 50
@export var equippedItem: Item = null
@onready var timer = $Timer
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
