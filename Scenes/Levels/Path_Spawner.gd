extends Node3D
class_name PathSpawner

@export var path: Path3D
@export var enemyScene: PackedScene
@export var waveGenerator: EndlessWaveGenerator

var currentWaveNumber: int = 1
var spawnedInWave: int = 0

var currentEnemyCount: int = 0
var currentInterval: float = 1.0
var currentArchetype: EnemyArchetype


func _ready() -> void:
	Game.game_over.connect(_on_game_over)

	_start_next_wave()


func _start_next_wave() -> void:
	if waveGenerator == null:
		return

	var waveData: Dictionary = waveGenerator.generate_wave(
		currentWaveNumber
	)

	currentEnemyCount = waveData["count"]
	currentInterval = waveData["interval"]
	currentArchetype = waveData["archetype"]

	spawnedInWave = 0

	$Timer.wait_time = currentInterval
	$Timer.start()


func _on_timer_timeout() -> void:
	if currentArchetype == null:
		return

	_spawn_enemy(currentArchetype)

	spawnedInWave += 1

	if spawnedInWave >= currentEnemyCount:
		$Timer.stop()

		currentWaveNumber += 1

		_start_next_wave()


func _spawn_enemy(archetype: EnemyArchetype) -> void:
	if enemyScene == null:
		return

	if path == null:
		return

	var enemy := enemyScene.instantiate() as Enemy

	if enemy == null:
		return

	enemy.archetype = archetype
	enemy.path = path

	%Enemies.add_child(enemy)


func _on_game_over() -> void:
	$Timer.stop()
