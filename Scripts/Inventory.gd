extends Node

signal inventory_changed(item: Item, newCount: int)

var items: Dictionary = {}

func add_item(item: Item, amount: int = 1) -> void:
	if item == null:
		return
	items[item] = get_count(item) + amount
	inventory_changed.emit(item, items[item])

func get_count(item: Item) -> int:
	return items.get(item, 0)

func remove_item(item: Item, amount: int = 1) -> bool:
	if get_count(item) < amount:
		return false
	items[item] -= amount
	inventory_changed.emit(item, items[item])
	return true
