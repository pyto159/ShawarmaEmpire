extends Resource
class_name EconomyConfig

const DEFAULT_GRILL_LEVEL: int = 1
const DEFAULT_COOKING_SPEED_MULTIPLIER: float = 1.0
const DEFAULT_RECIPE_REWARD: int = 0
const DEFAULT_INGREDIENT_COST: int = 0
const DEFAULT_GRILL_COST: int = 0

@export var grill_levels: Dictionary = {}
@export var ingredient_costs: Dictionary = {}
@export var recipe_rewards: Dictionary = {}
@export var cooking_multipliers: Dictionary = {}
@export var future_employee_costs: Dictionary = {}
@export var future_reputation_rewards: Dictionary = {}


func get_max_grill_level() -> int:
	var max_level: int = DEFAULT_GRILL_LEVEL
	for level: Variant in grill_levels.keys():
		max_level = maxi(max_level, int(level))

	return max_level


func get_grill_display_name(level: int) -> String:
	var level_data: Dictionary = _get_grill_level_data(level)
	return str(level_data.get("display_name", "Basic Grill"))


func get_grill_cost(level: int) -> int:
	var level_data: Dictionary = _get_grill_level_data(level)
	return int(level_data.get("cost", DEFAULT_GRILL_COST))


func get_cooking_multiplier(level: int) -> float:
	if cooking_multipliers.has(level):
		return float(cooking_multipliers[level])

	return float(cooking_multipliers.get(str(level), DEFAULT_COOKING_SPEED_MULTIPLIER))


func get_ingredient_cost(ingredient_id: String) -> int:
	return int(ingredient_costs.get(ingredient_id, DEFAULT_INGREDIENT_COST))


func get_recipe_reward(recipe: Recipe) -> int:
	if recipe == null:
		return DEFAULT_RECIPE_REWARD

	return get_recipe_reward_by_path(recipe.resource_path)


func get_recipe_reward_by_path(recipe_path: String) -> int:
	return int(recipe_rewards.get(recipe_path, DEFAULT_RECIPE_REWARD))


func _get_grill_level_data(level: int) -> Dictionary:
	if grill_levels.has(level):
		return grill_levels[level]

	return grill_levels.get(str(level), {})
