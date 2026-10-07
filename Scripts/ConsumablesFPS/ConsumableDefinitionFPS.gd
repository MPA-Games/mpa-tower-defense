class_name ConsumableDefinitionFPS
extends Resource

@export var item_id: StringName = &"consumable"
@export var display_name: String = "Consumable"
@export var icon: Texture2D
@export_range(0.1, 60.0, 0.1) var duration_seconds: float = 30.0
@export_range(0.5, 3.0, 0.05) var speed_multiplier: float = 1.0
@export_range(0.0, 5.0, 0.05) var dizzy_amount: float = 0.0
@export_group("Area")
@export var effect_type: StringName = &""
@export_range(0.0, 20.0, 0.5) var effect_radius: float = 0.0
@export var area_effect_scene: PackedScene = null
@export_range(0.0, 1.0, 0.05) var slow_multiplier: float = 1.0
@export_group("Attack")
@export var attack_modifier_id: StringName = &""
@export_range(1, 4, 1) var projectile_count: int = 1
@export_range(0.0, 30.0, 0.5) var projectile_spread_degrees: float = 0.0
@export var projectile_scene: PackedScene = null
