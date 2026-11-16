extends Resource
class_name EnemyArchetype

@export_category("Identity")
@export var archetypeId: StringName
@export var displayName: String

@export_category("Stats")
@export var speed: float = 2.0
@export var maxHealth: float = 10.0
@export var goldReward: int = 5

@export_category("Visual")
@export var visualScene: PackedScene
@export var visualScale: Vector3 = Vector3.ONE

@export_category("Drops")
@export var dropChance: float = 0.3
@export var dropPool: Array[Item] = []

@export_category("Future Resistances")
@export var resistances: Dictionary = {}
