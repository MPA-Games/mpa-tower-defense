extends CanvasLayer

func _ready() -> void:
	Game.gold_changed.connect(_on_gold_changed)
	Game.health_changed.connect(_on_health_changed)
	Game.game_over.connect(_on_game_over)
	Game.victory.connect(_on_victory)
	Inventory.inventory_changed.connect(_on_inventory_changed)
	%SelectionManager.structure_selected.connect(_on_structure_selected)
	_on_gold_changed(Game.gold)
	_on_health_changed(Game.health)
	refresh_inventory_display()

func _on_button_pressed() -> void:
	%BuildManager.toggle_placing()

func _on_gold_changed(new_value: int) -> void:
	%GoldLabel.text = "Oro: %d" % new_value

func _on_health_changed(new_value: int) -> void:
	%HealthLabel.text = "Vida: %d" % new_value

func _on_game_over() -> void:
	%GameOverPanel.visible = true

func _on_victory() -> void:
	%VictoryPanel.visible = true

func _on_structure_selected(structure: Structure) -> void:
	%StructurePanel.visible = structure != null
	if structure:
		refresh_item_buttons()

func _on_inventory_changed(_item: Item, _new_count: int) -> void:
	refresh_inventory_display()

func refresh_inventory_display() -> void:
	for child in %InventoryDisplay.get_children():
		child.queue_free()
	for item in Inventory.items.keys():
		if Inventory.items[item] <= 0:
			continue
		var label = Label.new()
		label.text = "%s: %d" % [item.itemName, Inventory.items[item]]
		%InventoryDisplay.add_child(label)

func refresh_item_buttons() -> void:
	for child in %ItemButtonsContainer.get_children():
		child.queue_free()
	for item in Inventory.items.keys():
		if Inventory.items[item] <= 0:
			continue
		var button = Button.new()
		button.text = "%s (x%d)" % [item.itemName, Inventory.items[item]]
		button.pressed.connect(_on_item_button_pressed.bind(item))
		%ItemButtonsContainer.add_child(button)

func _on_item_button_pressed(item: Item) -> void:
	if %SelectionManager.equip_item(item):
		refresh_item_buttons()
