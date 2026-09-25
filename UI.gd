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

	var structure: Structure = %SelectionManager.selectedStructure

	if structure != null:
		refresh_structure_panel(structure)

func _on_health_changed(new_value: int) -> void:
	%HealthLabel.text = "Vida: %d" % new_value

func _on_game_over() -> void:
	%GameOverPanel.visible = true

func _on_victory() -> void:
	%VictoryPanel.visible = true

func _on_structure_selected(structure: Structure) -> void:
	%StructurePanel.visible = structure != null

	if structure:
		refresh_structure_panel(structure)
		refresh_item_buttons()

func refresh_structure_panel(structure: Structure) -> void:
	%TowerName.text = structure.displayName

	%DamageLabel.text = "Daño: %.1f | Nv. %d" % [
		structure.damage,
		structure.damageLevel
	]

	%RangeLabel.text = "Rango: %.1f | Nv. %d" % [
		structure.attackRange,
		structure.rangeLevel
	]

	%AttackSpeedLabel.text = "Cooldown: %.2f s | Nv. %d" % [
		structure.attackCooldown,
		structure.attackSpeedLevel
	]

	%ResourceEffectLabel.text = "Efecto recurso: x%.2f | Nv. %d" % [
		structure.resourceEffectMultiplier,
		structure.resourceEffectLevel
	]
	# DAMAGE
	if structure.damageLevel >= structure.maxUpgradeLevel:
		%DamageUpgradeButton.text = "Daño - MAX"
		%DamageUpgradeButton.disabled = true
	else:
		var damageCost := structure.get_damage_upgrade_cost()
		%DamageUpgradeButton.text = "Mejorar daño - %d oro" % damageCost
		%DamageUpgradeButton.disabled = Game.gold < damageCost


	# RANGE
	if structure.rangeLevel >= structure.maxUpgradeLevel:
		%RangeUpgradeButton.text = "Rango - MAX"
		%RangeUpgradeButton.disabled = true
	else:
		var rangeCost := structure.get_range_upgrade_cost()
		%RangeUpgradeButton.text = "Mejorar rango - %d oro" % rangeCost
		%RangeUpgradeButton.disabled = Game.gold < rangeCost


	# ATTACK SPEED
	if structure.attackSpeedLevel >= structure.maxUpgradeLevel:
		%AttackSpeedUpgradeButton.text = "Velocidad - MAX"
		%AttackSpeedUpgradeButton.disabled = true
	else:
		var speedCost := structure.get_attack_speed_upgrade_cost()
		%AttackSpeedUpgradeButton.text = "Mejorar velocidad - %d oro" % speedCost
		%AttackSpeedUpgradeButton.disabled = Game.gold < speedCost


	# RESOURCE EFFECT
	if structure.resourceEffectLevel >= structure.maxUpgradeLevel:
		%ResourceUpgradeButton.text = "Recurso - MAX"
		%ResourceUpgradeButton.disabled = true
	else:
		var resourceCost := structure.get_resource_effect_upgrade_cost()
		%ResourceUpgradeButton.text = "Mejorar recurso - %d oro" % resourceCost
		%ResourceUpgradeButton.disabled = Game.gold < resourceCost

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

func _on_damage_upgrade_button_pressed() -> void:
	var structure: Structure = %SelectionManager.selectedStructure

	if structure == null:
		return

	structure.upgrade_damage()
	refresh_structure_panel(structure)

func _on_range_upgrade_button_pressed() -> void:
	var structure: Structure = %SelectionManager.selectedStructure

	if structure == null:
		return

	structure.upgrade_range()
	refresh_structure_panel(structure)

func _on_attack_speed_upgrade_button_pressed() -> void:
	var structure: Structure = %SelectionManager.selectedStructure

	if structure == null:
		return

	structure.upgrade_attack_speed()
	refresh_structure_panel(structure)

func _on_resource_upgrade_button_pressed() -> void:
	var structure: Structure = %SelectionManager.selectedStructure

	if structure == null:
		return

	structure.upgrade_resource_effect()
	refresh_structure_panel(structure)
