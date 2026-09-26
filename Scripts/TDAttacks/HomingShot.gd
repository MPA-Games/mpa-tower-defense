extends ShotBehavior
class_name HomingShot

@export var projectileScene: PackedScene

func fire(tower: Structure, target: Enemy) -> void:
	if projectileScene == null:
		return

	var projectile = projectileScene.instantiate()

	tower.get_tree().current_scene.add_child(projectile)

	projectile.global_position = tower.global_position
	projectile.target = target
	projectile.damage = tower.damage
	projectile.equippedItem = tower.equippedItem
	projectile.resourceEffectMultiplier = tower.resourceEffectMultiplier
