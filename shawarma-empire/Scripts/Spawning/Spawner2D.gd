extends Node2D
class_name Spawner2D

signal spawn_succeeded(instance: Node, definition: SpawnDefinition, spawn_point: SpawnPoint2D)
signal spawn_failed(reason: String)

const SPAWN_FAILED_NO_POOL: String = "Spawn pool is not assigned."
const SPAWN_FAILED_NO_DEFINITION: String = "No spawn definition is available."
const SPAWN_FAILED_NO_POINT: String = "No spawn point is available."
const SPAWN_FAILED_INVALID_PARENT: String = "Spawn parent is not available."

@export var spawn_pool: SpawnPool
@export var spawn_parent: Node
@export var auto_collect_child_spawn_points: bool = true
@export var randomize_seed_on_ready: bool = true
@export var reserve_spawn_points_until_instance_removed: bool = true

var spawn_points: Array[SpawnPoint2D] = []
var active_counts: Dictionary = {}

var _random_number_generator: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	if spawn_parent == null:
		spawn_parent = self

	if auto_collect_child_spawn_points:
		collect_child_spawn_points()

	if randomize_seed_on_ready:
		_random_number_generator.randomize()


func collect_child_spawn_points() -> void:
	spawn_points.clear()
	_add_spawn_points_from_node(self)


func add_spawn_point(spawn_point: SpawnPoint2D) -> void:
	if spawn_point == null or spawn_points.has(spawn_point):
		return

	spawn_points.append(spawn_point)


func remove_spawn_point(spawn_point: SpawnPoint2D) -> void:
	spawn_points.erase(spawn_point)


func try_spawn() -> Node:
	if spawn_pool == null:
		spawn_failed.emit(SPAWN_FAILED_NO_POOL)
		return null

	var definition: SpawnDefinition = spawn_pool.pick_definition(_random_number_generator, active_counts)
	if definition == null:
		spawn_failed.emit(SPAWN_FAILED_NO_DEFINITION)
		return null

	return spawn_definition(definition)


func spawn_definition(definition: SpawnDefinition) -> Node:
	if definition == null or definition.scene == null:
		spawn_failed.emit(SPAWN_FAILED_NO_DEFINITION)
		return null

	var spawn_point: SpawnPoint2D = get_available_spawn_point()
	if spawn_point == null:
		spawn_failed.emit(SPAWN_FAILED_NO_POINT)
		return null

	if spawn_parent == null:
		spawn_failed.emit(SPAWN_FAILED_INVALID_PARENT)
		return null

	var instance: Node = definition.scene.instantiate()
	spawn_parent.add_child(instance)
	if instance is Node2D:
		(instance as Node2D).global_position = spawn_point.global_position

	_register_spawn(instance, definition, spawn_point)
	return instance


func get_available_spawn_point() -> SpawnPoint2D:
	var available_spawn_points: Array[SpawnPoint2D] = []
	for spawn_point: SpawnPoint2D in spawn_points:
		if spawn_point != null and spawn_point.can_spawn():
			available_spawn_points.append(spawn_point)

	if available_spawn_points.is_empty():
		return null

	var selected_index: int = _random_number_generator.randi_range(0, available_spawn_points.size() - 1)
	return available_spawn_points[selected_index]


func notify_instance_removed(definition: SpawnDefinition) -> void:
	var active_instances: int = int(active_counts.get(definition, 0))
	active_counts[definition] = max(active_instances - 1, 0)


func _register_spawn(instance: Node, definition: SpawnDefinition, spawn_point: SpawnPoint2D) -> void:
	active_counts[definition] = int(active_counts.get(definition, 0)) + 1
	if reserve_spawn_points_until_instance_removed:
		spawn_point.reserve()

	instance.tree_exiting.connect(_on_spawned_instance_tree_exiting.bind(definition, spawn_point), CONNECT_ONE_SHOT)
	spawn_succeeded.emit(instance, definition, spawn_point)


func _on_spawned_instance_tree_exiting(definition: SpawnDefinition, spawn_point: SpawnPoint2D) -> void:
	notify_instance_removed(definition)
	if reserve_spawn_points_until_instance_removed and spawn_point != null:
		spawn_point.release()


func _add_spawn_points_from_node(node: Node) -> void:
	for child: Node in node.get_children():
		if child is SpawnPoint2D:
			add_spawn_point(child as SpawnPoint2D)

		_add_spawn_points_from_node(child)
