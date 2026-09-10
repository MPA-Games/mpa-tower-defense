extends Node3D

@export var path: Path3D
@export var waves: Array[Wave]
var currentWaveIndex: int
var spawnedInWave: int


func _on_timer_timeout() -> void:
	if currentWaveIndex >= waves.size():
		$Timer.stop()
		return
	var currentWave = waves[currentWaveIndex]
	var enemy = currentWave.enemyScene.instantiate()
	enemy.path = path
	%Enemies.add_child(enemy)
	spawnedInWave +=1
	if (spawnedInWave >= currentWave.count):
		currentWaveIndex +=1
		spawnedInWave = 0
		if (currentWaveIndex < waves.size()):
			$Timer.wait_time = waves[currentWaveIndex].interval
