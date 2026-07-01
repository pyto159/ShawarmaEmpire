extends Resource
class_name SpawnDefinition

const DEFAULT_WEIGHT: int = 1
const DEFAULT_MAX_ACTIVE_INSTANCES: int = 0

@export var scene: PackedScene
@export_range(1, 1000, 1) var weight: int = DEFAULT_WEIGHT
@export var max_active_instances: int = DEFAULT_MAX_ACTIVE_INSTANCES


func can_spawn(active_instances: int) -> bool:
	if scene == null:
		return false

	if max_active_instances <= DEFAULT_MAX_ACTIVE_INSTANCES:
		return true

	return active_instances < max_active_instances
