extends Resource
class_name EconomyConfig

const DEFAULT_GRILL_LEVEL: int = 1
const DEFAULT_COOKING_SPEED_MULTIPLIER: float = 1.00
const DEFAULT_RECIPE_REWARD: int = 0
const DEFAULT_RECIPE_PREPARATION_TIME: float = 1.00
const DEFAULT_INGREDIENT_COST: int = 0
const DEFAULT_GRILL_COST: int = 0
const DEFAULT_KIOSK_UPGRADE_COST: int = 0
const DEFAULT_KIOSK_UPGRADE_EFFECT: float = 1.0
const DEFAULT_TIP_CHANCE: float = 0.20
const DEFAULT_TIP_MIN_PERCENT: float = 0.05
const DEFAULT_TIP_MAX_PERCENT: float = 0.25
const DEFAULT_COMBO_LEVEL: int = 1
const FALLBACK_COMBO_BONUS_TABLE: Dictionary = {
	1: 0.00,
	2: 0.05,
	3: 0.10,
	4: 0.15,
	5: 0.20,
	6: 0.25,
	7: 0.30,
	8: 0.35,
	9: 0.40,
	10: 0.50,
}
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
	"onion": 350,
	"bbq_sauce": 450,
	"double_chicken": 600,
	"lettuce": 300,
}
const FALLBACK_RECIPE_REWARDS: Dictionary = {
	"res://Resources/Recipes/ClassicShawarma.tres": 15,
	"res://Resources/Recipes/SpicyShawarma.tres": 24,
	"res://Resources/Recipes/CheeseShawarma.tres": 35,
	"res://Resources/Recipes/BBQShawarma.tres": 50,
	"res://Resources/Recipes/DoubleMeatShawarma.tres": 65,
	"res://Resources/Recipes/VeggieShawarma.tres": 45,
	"res://Resources/Recipes/MegaShawarma.tres": 90,
}
const FALLBACK_RECIPE_PREPARATION_TIMES: Dictionary = {
	"res://Resources/Recipes/ClassicShawarma.tres": 3.00,
	"res://Resources/Recipes/SpicyShawarma.tres": 3.60,
	"res://Resources/Recipes/CheeseShawarma.tres": 4.00,
	"res://Resources/Recipes/BBQShawarma.tres": 4.50,
	"res://Resources/Recipes/DoubleMeatShawarma.tres": 5.00,
	"res://Resources/Recipes/VeggieShawarma.tres": 4.20,
	"res://Resources/Recipes/MegaShawarma.tres": 6.00,
}
const FALLBACK_COOKING_MULTIPLIERS: Dictionary = {
	1: 1.00,
	2: 0.90,
	3: 0.75,
	4: 0.60,
	5: 0.45,
}
const FALLBACK_KIOSK_UPGRADES: Dictionary = {
	&"better_counter": {
		"display_name": "Better Counter",
		"levels": {
			1: {"cost": 0, "effect": 1.00}, 2: {"cost": 300, "effect": 1.05},
			3: {"cost": 900, "effect": 1.10}, 4: {"cost": 2500, "effect": 1.18},
			5: {"cost": 6500, "effect": 1.28},
		},
	},
	&"new_sign": {
		"display_name": "New Sign",
		"levels": {
			1: {"cost": 0, "effect": 1.00}, 2: {"cost": 450, "effect": 0.94},
			3: {"cost": 1300, "effect": 0.87}, 4: {"cost": 3600, "effect": 0.78},
			5: {"cost": 9000, "effect": 0.68},
		},
	},
}

@export var grill_levels: Dictionary = {}
@export var ingredient_costs: Dictionary = {}
@export var recipe_rewards: Dictionary = {}
@export var recipe_preparation_times: Dictionary = {}
@export var cooking_multipliers: Dictionary = {}
@export var kiosk_upgrades: Dictionary = {}
@export_range(0.0, 1.0, 0.01) var tip_chance: float = DEFAULT_TIP_CHANCE
@export_range(0.0, 1.0, 0.01) var tip_min_percent: float = DEFAULT_TIP_MIN_PERCENT
@export_range(0.0, 1.0, 0.01) var tip_max_percent: float = DEFAULT_TIP_MAX_PERCENT
@export var combo_bonus_table: Dictionary = {}
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


func get_kiosk_upgrades() -> Dictionary:
	if kiosk_upgrades.is_empty():
		return FALLBACK_KIOSK_UPGRADES

	return kiosk_upgrades


func get_kiosk_upgrade_ids() -> Array[StringName]:
	var upgrade_ids: Array[StringName] = []
	for upgrade_id: Variant in get_kiosk_upgrades().keys():
		upgrade_ids.append(StringName(str(upgrade_id)))
	return upgrade_ids


func has_kiosk_upgrade(upgrade_id: StringName) -> bool:
	return get_kiosk_upgrades().has(upgrade_id) or get_kiosk_upgrades().has(String(upgrade_id))


func get_upgrade_display_name(upgrade_id: StringName) -> String:
	return str(_get_kiosk_upgrade_data(upgrade_id).get("display_name", String(upgrade_id).capitalize()))


func get_upgrade_max_level(upgrade_id: StringName) -> int:
	var max_level: int = 0
	for level: Variant in _get_upgrade_levels(upgrade_id).keys():
		max_level = maxi(max_level, int(level))
	return max_level


func get_upgrade_cost(upgrade_id: StringName, level: int) -> int:
	var level_data: Dictionary = _get_value_for_level(_get_upgrade_levels(upgrade_id), level, {}) as Dictionary
	return int(level_data.get("cost", DEFAULT_KIOSK_UPGRADE_COST))


func get_upgrade_effect(upgrade_id: StringName, level: int) -> float:
	var safe_level: int = clampi(level, 1, maxi(get_upgrade_max_level(upgrade_id), 1))
	var level_data: Dictionary = _get_value_for_level(_get_upgrade_levels(upgrade_id), safe_level, {}) as Dictionary
	return float(level_data.get("effect", DEFAULT_KIOSK_UPGRADE_EFFECT))


func _get_kiosk_upgrade_data(upgrade_id: StringName) -> Dictionary:
	return get_kiosk_upgrades().get(upgrade_id, get_kiosk_upgrades().get(String(upgrade_id), {})) as Dictionary


func _get_upgrade_levels(upgrade_id: StringName) -> Dictionary:
	return _get_kiosk_upgrade_data(upgrade_id).get("levels", {}) as Dictionary


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


func get_tip_chance() -> float:
	return clampf(tip_chance, 0.0, 1.0)


func get_tip_min_percent() -> float:
	return clampf(minf(tip_min_percent, tip_max_percent), 0.0, 1.0)


func get_tip_max_percent() -> float:
	return clampf(maxf(tip_min_percent, tip_max_percent), 0.0, 1.0)


func get_max_combo_level() -> int:
	var max_level: int = DEFAULT_COMBO_LEVEL
	for level: Variant in _get_combo_bonus_table().keys():
		max_level = maxi(max_level, int(level))

	return max_level


func get_combo_bonus_percent(combo_level: int) -> float:
	var safe_level: int = clampi(combo_level, DEFAULT_COMBO_LEVEL, get_max_combo_level())
	return float(_get_value_for_level(_get_combo_bonus_table(), safe_level, 0.0))


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


func _get_combo_bonus_table() -> Dictionary:
	if combo_bonus_table.is_empty():
		return FALLBACK_COMBO_BONUS_TABLE

	return combo_bonus_table
