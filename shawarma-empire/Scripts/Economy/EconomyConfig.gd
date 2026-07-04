extends Resource
class_name EconomyConfig

const DEFAULT_GRILL_LEVEL: int = 1
const DEFAULT_COOKING_SPEED_MULTIPLIER: float = 1.0
const DEFAULT_RECIPE_REWARD: int = 0
const DEFAULT_RECIPE_PREPARATION_TIME: float = 1.0
const DEFAULT_INGREDIENT_COST: int = 0
const DEFAULT_GRILL_COST: int = 0
const FALLBACK_GRILL_DISPLAY_NAME: String = "Basic Grill"
const FALLBACK_GRILL_LEVELS: Dictionary = {
	1: {"display_name": "Basic Grill", "cost": 0},
	2: {"display_name": "Better Grill", "cost": 50},
	3: {"display_name": "Fast Grill", "cost": 150},
	4: {"display_name": "Professional Grill", "cost": 400},
	5: {"display_name": "Master Grill", "cost": 900},
}
const FALLBACK_INGREDIENT_COSTS: Dictionary = {
	"jalapeno": 100,
	"spicy_sauce": 150,
	"cheese": 250,
}
const FALLBACK_RECIPE_REWARDS: Dictionary = {
	"res://Resources/Recipes/ClassicShawarma.tres": 15,
	"res://Resources/Recipes/SpicyShawarma.tres": 24,
	"res://Resources/Recipes/CheeseShawarma.tres": 35,
}
const FALLBACK_RECIPE_PREPARATION_TIMES: Dictionary = {
	"res://Resources/Recipes/ClassicShawarma.tres": 3.0,
	"res://Resources/Recipes/SpicyShawarma.tres": 3.6,
	"res://Resources/Recipes/CheeseShawarma.tres": 4.0,
}
const FALLBACK_COOKING_MULTIPLIERS: Dictionary = {
	1: 1.0,
	2: 0.9,
	3: 0.75,
	4: 0.6,
	5: 0.45,
}

@export var grill_levels: Dictionary = {}
@export var ingredient_costs: Dictionary = {}
@export var recipe_rewards: Dictionary = {}
@export var recipe_preparation_times: Dictionary = {}
@export var cooking_multipliers: Dictionary = {}
@export var future_employee_costs: Dictionary = {}
@export var future_reputation_rewards: Dictionary = {}


static func load_or_default(config_path: String) -> EconomyConfig:
	var loaded_config: EconomyConfig = load(config_path) as EconomyConfig
	if loaded_config != null:
		return loaded_config

	push_warning("EconomyConfig missing or invalid at %s; using safe fallback balance values." % config_path)
	return EconomyConfig.new()


func get_max_grill_level() -> int:
	var max_level: int = DEFAULT_GRILL_LEVEL
	for level: Variant in _get_grill_levels().keys():
		max_level = maxi(max_level, int(level))

	return max_level


func get_grill_display_name(level: int) -> String:
	var level_data: Dictionary = _get_grill_level_data(level)
	return str(level_data.get("display_name", FALLBACK_GRILL_DISPLAY_NAME))


func get_grill_cost(level: int) -> int:
	var level_data: Dictionary = _get_grill_level_data(level)
	return int(level_data.get("cost", DEFAULT_GRILL_COST))


func get_cooking_multiplier(level: int) -> float:
	return float(_get_value_for_level(_get_cooking_multipliers(), level, DEFAULT_COOKING_SPEED_MULTIPLIER))


func get_ingredient_cost(ingredient_id: String) -> int:
	return int(_get_ingredient_costs().get(ingredient_id, DEFAULT_INGREDIENT_COST))


func get_recipe_reward(recipe: Recipe) -> int:
	if recipe == null:
		return DEFAULT_RECIPE_REWARD

	return get_recipe_reward_by_path(recipe.resource_path)


func get_recipe_reward_by_path(recipe_path: String) -> int:
	return int(_get_recipe_rewards().get(recipe_path, DEFAULT_RECIPE_REWARD))


func get_recipe_preparation_time(recipe: Recipe) -> float:
	if recipe == null:
		return DEFAULT_RECIPE_PREPARATION_TIME

	return get_recipe_preparation_time_by_path(recipe.resource_path)


func get_recipe_preparation_time_by_path(recipe_path: String) -> float:
	return float(_get_recipe_preparation_times().get(recipe_path, DEFAULT_RECIPE_PREPARATION_TIME))


func _get_grill_level_data(level: int) -> Dictionary:
	return _get_value_for_level(_get_grill_levels(), level, {}) as Dictionary


func _get_value_for_level(values: Dictionary, level: int, default_value: Variant) -> Variant:
	if values.has(level):
		return values[level]

	return values.get(str(level), default_value)


func _get_grill_levels() -> Dictionary:
	if grill_levels.is_empty():
		return FALLBACK_GRILL_LEVELS

	return grill_levels


func _get_ingredient_costs() -> Dictionary:
	if ingredient_costs.is_empty():
		return FALLBACK_INGREDIENT_COSTS

	return ingredient_costs


func _get_recipe_rewards() -> Dictionary:
	if recipe_rewards.is_empty():
		return FALLBACK_RECIPE_REWARDS

	return recipe_rewards


func _get_recipe_preparation_times() -> Dictionary:
	if recipe_preparation_times.is_empty():
		return FALLBACK_RECIPE_PREPARATION_TIMES

	return recipe_preparation_times


func _get_cooking_multipliers() -> Dictionary:
	if cooking_multipliers.is_empty():
		return FALLBACK_COOKING_MULTIPLIERS

	return cooking_multipliers
