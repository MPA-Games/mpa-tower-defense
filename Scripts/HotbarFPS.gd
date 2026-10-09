class_name HotbarFPS
extends Control

const SLOT_SIZE := Vector2(72.0, 72.0)
const SLOT_GAP := 8.0
const HOTBAR_WIDTH := SLOT_SIZE.x * 4.0 + SLOT_GAP * 3.0

var _inventory: InventoryAdapterFPS
var _effects: EffectControllerFPS
var _effect_progress: Dictionary = {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	queue_redraw()

func configure(inventory: InventoryAdapterFPS, effects: EffectControllerFPS) -> void:
	_inventory = inventory
	_effects = effects
	_inventory.inventory_changed.connect(queue_redraw)
	_inventory.selection_changed.connect(func(_slot: int): queue_redraw())
	_effects.effect_duration_changed.connect(_on_effect_duration_changed)
	queue_redraw()

func _draw() -> void:
	if _inventory == null:
		return
	var origin := Vector2((size.x - HOTBAR_WIDTH) / 2.0, size.y - SLOT_SIZE.y - 28.0)
	for slot in InventoryFPS.MAX_SLOTS:
		var slot_position := origin + Vector2(slot * (SLOT_SIZE.x + SLOT_GAP), 0.0)
		var selected := slot == _inventory.get_selected_slot()
		var background := Color("26313b") if not selected else Color("3e6872")
		var border := Color("71808c") if not selected else Color("d7f2e9")
		draw_style_box(_make_box(background, border, 3.0), Rect2(slot_position, SLOT_SIZE))
		_draw_slot_icon(slot_position, slot)
		_draw_effect_progress(slot_position, slot)
		draw_string(ThemeDB.fallback_font, slot_position + Vector2(9.0, 20.0), str(slot + 1), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, Color("d7f2e9"))
		draw_string(ThemeDB.fallback_font, slot_position + Vector2(53.0, 63.0), str(_inventory.get_quantity(slot)), HORIZONTAL_ALIGNMENT_RIGHT, 12.0, 14, Color.WHITE)

func _draw_slot_icon(slot_position: Vector2, slot: int) -> void:
	var definition := _inventory.get_definition(slot)
	if definition == null or definition.icon == null:
		return
	var icon_rect := Rect2(slot_position + Vector2(12.0, 12.0), Vector2(48.0, 48.0))
	draw_texture_rect(definition.icon, icon_rect, false)

func _draw_effect_progress(slot_position: Vector2, slot: int) -> void:
	if not _effect_progress.has(slot):
		return
	var progress: float = _effect_progress[slot]
	var elapsed := 1.0 - progress
	var cooldown_rect := Rect2(
		slot_position,
		Vector2(SLOT_SIZE.x, SLOT_SIZE.y * elapsed)
	)
	draw_rect(cooldown_rect, Color(0.05, 0.08, 0.1, 0.62), true)

func _on_effect_duration_changed(slot: int, time_remaining: float, duration: float) -> void:
	if slot < 0 or duration <= 0.0 or time_remaining <= 0.0:
		_effect_progress.erase(slot)
	else:
		_effect_progress[slot] = clampf(time_remaining / duration, 0.0, 1.0)
	queue_redraw()

func _make_box(background: Color, border: Color, radius: float) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = background
	box.border_color = border
	box.set_border_width_all(2)
	box.set_corner_radius_all(int(radius))
	return box
