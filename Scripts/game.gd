extends Node

signal gold_changed(new_value: int)
signal health_changed(new_value: int)
signal game_over
signal victory

var wavesCompleted : bool = false
var gold: int = 100
var health: int = 20

func add_gold(amount: int) -> void:
	gold += amount
	gold_changed.emit(gold)

func spend_gold(amount: int) -> bool:
	if gold < amount:
		return false
	gold -= amount
	gold_changed.emit(gold)
	return true

func damage_health(amount: int) -> void:
	health -= amount
	health_changed.emit(health)
	if health <= 0:
		health = 0
		game_over.emit()

func waves_completed()-> void:
	wavesCompleted = true
	checkVictory()

func checkVictory()-> void:
	if not wavesCompleted:
		return
	if health <= 0:
		return
	if get_tree().get_nodes_in_group("enemies").size() > 0:
		return
	victory.emit()
