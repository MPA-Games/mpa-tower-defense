extends Node
class_name EndlessWaveGenerator

@export var archetypes: Array[EnemyArchetype]

@export_category("Wave Scaling")
@export var baseEnemyCount: int = 5
@export var enemiesAddedPerWave: int = 2

@export var baseInterval: float = 2.0
@export var intervalReductionPerWave: float = 0.05
@export var minimumInterval: float = 0.35


func generate_wave(waveNumber: int) -> Dictionary:
	var enemyCount: int = (
		baseEnemyCount
		+ enemiesAddedPerWave * (waveNumber - 1)
	)

	var interval: float = maxf(
		minimumInterval,
		baseInterval
		- intervalReductionPerWave * (waveNumber - 1)
	)

	var archetype: EnemyArchetype = _choose_archetype(waveNumber)

	return {
		"archetype": archetype,
		"count": enemyCount,
		"interval": interval
	}


func _choose_archetype(waveNumber: int) -> EnemyArchetype:
	if archetypes.is_empty():
		return null

	var unlockedCount: int = 1

	if waveNumber >= 3:
		unlockedCount = mini(2, archetypes.size())

	if waveNumber >= 6:
		unlockedCount = mini(3, archetypes.size())

	var randomIndex: int = randi_range(
		0,
		unlockedCount - 1
	)

	return archetypes[randomIndex]
