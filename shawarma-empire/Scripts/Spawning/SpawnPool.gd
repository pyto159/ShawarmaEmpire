extends Resource
class_name SpawnPool

@export var definitions: Array[SpawnDefinition] = []


func get_available_definitions(active_counts: Dictionary) -> Array[SpawnDefinition]:
	var available_definitions: Array[SpawnDefinition] = []
	for definition: SpawnDefinition in definitions:
		if definition == null:
			continue

		var active_instances: int = int(active_counts.get(definition, 0))
		if definition.can_spawn(active_instances):
			available_definitions.append(definition)

	return available_definitions


func get_total_weight(available_definitions: Array[SpawnDefinition]) -> int:
	var total_weight: int = 0
	for definition: SpawnDefinition in available_definitions:
		total_weight += definition.weight

	return total_weight


func pick_definition(random_number_generator: RandomNumberGenerator, active_counts: Dictionary) -> SpawnDefinition:
	var available_definitions: Array[SpawnDefinition] = get_available_definitions(active_counts)
	var total_weight: int = get_total_weight(available_definitions)
	if total_weight <= 0:
		return null

	var selected_weight: int = random_number_generator.randi_range(1, total_weight)
	var accumulated_weight: int = 0
	for definition: SpawnDefinition in available_definitions:
		accumulated_weight += definition.weight
		if selected_weight <= accumulated_weight:
			return definition

	return null
