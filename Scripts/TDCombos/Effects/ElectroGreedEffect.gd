extends ComboEffect
class_name ElectroGreedEffect

@export var targetArchetype: EnemyArchetype


func can_activate(target: Enemy) -> bool:
	if not is_instance_valid(target):
		return false

	if target.isDead:
		return false

	if targetArchetype == null:
		return false

	# Si ya es ese arquetipo, no gastamos el combo.
	if target.archetype == targetArchetype:
		return false

	return true


func activate(target: Enemy, _runtime: Dictionary) -> void:
	target.change_archetype(targetArchetype)
