extends Node3D
class_name BuildManager

var isPlacing: bool = false
var ghost: Node3D = null
var lastValidPosition: Vector3 = Vector3.ZERO
var lastPlacementValid: bool = false
@export var structureScene: PackedScene
@export var invalidTileIds: Array[int]
var validMaterial := StandardMaterial3D.new()
var invalidMaterial := StandardMaterial3D.new()

func _ready() -> void:
	validMaterial.albedo_color = Color(0, 1, 0, 0.8)
	validMaterial.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	invalidMaterial.albedo_color = Color(1, 0, 0, 0.8)
	invalidMaterial.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

func toggle_placing() -> void:
	if isPlacing:
		stop_placing()
	else:
		start_placing()

func start_placing() -> void:
	isPlacing = true
	ghost = structureScene.instantiate()
	add_child(ghost)
	for shape in ghost.find_children("", "CollisionShape3D", true):
		shape.disabled = true

func stop_placing() -> void:
	isPlacing = false
	if ghost:
		ghost.queue_free()
		ghost = null

func _process(_delta: float) -> void:
	if not isPlacing:
		return
	var mousePos = get_viewport().get_mouse_position()
	var from = %Camera.project_ray_origin(mousePos)
	var to = from + %Camera.project_ray_normal(mousePos) * 1000
	var query = PhysicsRayQueryParameters3D.create(from, to, 1)
	var result = get_viewport().find_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return
	ghost.global_position = result.position
	lastValidPosition = result.position
	lastPlacementValid = is_valid_placement(result.position, ghost.placementRadius)
	var materialToUse = validMaterial if lastPlacementValid else invalidMaterial
	for meshInstance in ghost.find_children("", "MeshInstance3D", true):
		meshInstance.material_override = materialToUse

func is_valid_placement(pos: Vector3, radius: float) -> bool:
	var cell = %GridMap.local_to_map(%GridMap.to_local(pos))
	cell.y = 0
	var tileId = %GridMap.get_cell_item(cell)
	if tileId in invalidTileIds:
		return false
	var flatPos = Vector3(pos.x, 0, pos.z)
	for existing in %Structures.get_children():
		var flatExisting = Vector3(existing.global_position.x, 0, existing.global_position.z)
		if flatPos.distance_to(flatExisting) < radius + existing.placementRadius:
			return false
	return true

func _unhandled_input(event: InputEvent) -> void:
	if (isPlacing and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		var from = %Camera.project_ray_origin(event.position)
		var to = from + %Camera.project_ray_normal(event.position) * 1000
		var query = PhysicsRayQueryParameters3D.create(from, to, 1)
		var result = get_viewport().find_world_3d().direct_space_state.intersect_ray(query)
		if result.is_empty():
			return
		var newStructure = structureScene.instantiate()
		if not is_valid_placement(result.position, newStructure.placementRadius):
			newStructure.queue_free()
			return
		if not Game.spend_gold(newStructure.cost):
			newStructure.queue_free()
			return
		%Structures.add_child(newStructure)
		newStructure.global_position = result.position
		stop_placing()
