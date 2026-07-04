extends Node

signal currency_changed(coins: int, gems: int)
signal upgrades_changed
signal recipes_changed

const STARTING_COINS: int = 0
const STARTING_GEMS: int = 0
const DEFAULT_GRILL_LEVEL: int = 1
const MAX_GRILL_LEVEL: int = 4
const DEFAULT_COOKING_SPEED_MULTIPLIER: float = 1.0
const SAVE_KEY_GRILL_LEVEL: String = "grill_level"
const SAVE_KEY_PURCHASED_UPGRADES: String = "purchased_upgrades"
const SAVE_KEY_UNLOCKED_RECIPES: String = "unlocked_recipes"
const SAVE_KEY_UNLOCKED_INGREDIENTS: String = "unlocked_ingredients"
const SAVE_KEY_GAME_VERSION: String = "game_version"
const GAME_VERSION: String = "0.8.0"
const DEFAULT_UNLOCKED_RECIPE_PATHS: Array[String] = [
	"res://Resources/Recipes/ClassicShawarma.tres",
	"res://Resources/Recipes/SpicyShawarma.tres",
	"res://Resources/Recipes/CheeseShawarma.tres",
]
const GRILL_LEVEL_DATA: Dictionary = {
	1: {"display_name": "Basic Grill", "cost": 0, "cooking_speed_multiplier": 1.0},
	2: {"display_name": "Better Grill", "cost": 50, "cooking_speed_multiplier": 0.90},
	3: {"display_name": "Fast Grill", "cost": 150, "cooking_speed_multiplier": 0.75},
	4: {"display_name": "Pro Grill", "cost": 400, "cooking_speed_multiplier": 0.60},
}

var coins: int = STARTING_COINS
var gems: int = STARTING_GEMS
var purchased_upgrade_ids: Array[StringName] = []
var grill_level: int = DEFAULT_GRILL_LEVEL
var cooking_speed_multiplier: float = DEFAULT_COOKING_SPEED_MULTIPLIER
var unlocked_recipe_paths: Array[String] = DEFAULT_UNLOCKED_RECIPE_PATHS.duplicate()
var unlocked_ingredient_ids: Array[String] = []


func initialize_new_game() -> void:
	set_currency(STARTING_COINS, STARTING_GEMS)
	purchased_upgrade_ids.clear()
	unlocked_recipe_paths = DEFAULT_UNLOCKED_RECIPE_PATHS.duplicate()
	unlocked_ingredient_ids.clear()
	set_grill_level(DEFAULT_GRILL_LEVEL)
	recipes_changed.emit()


func add_coins(amount: int) -> void:
	if amount <= 0:
		return

	set_currency(coins + amount, gems)


func spend_coins(amount: int) -> bool:
	if amount <= 0 or coins < amount:
		return false

	set_currency(coins - amount, gems)
	return true


func purchase_next_grill_level() -> bool:
	var next_level: int = get_next_grill_level()
	if next_level > MAX_GRILL_LEVEL:
		return false

	var cost: int = get_grill_level_cost(next_level)
	if not spend_coins(cost):
		return false

	set_grill_level(next_level)
	SaveManager.queue_save_game()
	return true


func get_next_grill_level() -> int:
	return grill_level + 1


func is_max_grill_level() -> bool:
	return grill_level >= MAX_GRILL_LEVEL


func get_grill_level_display_name(level: int = DEFAULT_GRILL_LEVEL) -> String:
	var display_level: int = level
	if display_level < DEFAULT_GRILL_LEVEL:
		display_level = grill_level

	var level_data: Dictionary = _get_grill_level_data(display_level)
	return str(level_data.get("display_name", "Basic Grill"))


func get_grill_level_cost(level: int) -> int:
	var level_data: Dictionary = _get_grill_level_data(level)
	return int(level_data.get("cost", 0))


func get_next_grill_button_text() -> String:
	if is_max_grill_level():
		return "Max Grill"

	var next_level: int = get_next_grill_level()
	return "%s - %d Coins" % [get_grill_level_display_name(next_level), get_grill_level_cost(next_level)]


func set_grill_level(level: int) -> void:
	grill_level = clampi(level, DEFAULT_GRILL_LEVEL, MAX_GRILL_LEVEL)
	cooking_speed_multiplier = _get_grill_level_multiplier(grill_level)
	upgrades_changed.emit()


func purchase_upgrade(upgrade: UpgradeData) -> bool:
	if upgrade == null or has_upgrade(upgrade.id):
		return false

	if not spend_coins(upgrade.cost):
		return false

	purchased_upgrade_ids.append(upgrade.id)
	upgrades_changed.emit()
	SaveManager.queue_save_game()
	return true


func has_upgrade(upgrade_id: StringName) -> bool:
	return purchased_upgrade_ids.has(upgrade_id)


func set_currency(new_coins: int, new_gems: int) -> void:
	coins = max(new_coins, 0)
	gems = max(new_gems, 0)
	currency_changed.emit(coins, gems)


func get_save_data() -> Dictionary:
	return {
		"coins": coins,
		"gems": gems,
		SAVE_KEY_GRILL_LEVEL: grill_level,
		SAVE_KEY_PURCHASED_UPGRADES: _get_purchased_upgrade_save_ids(),
		SAVE_KEY_UNLOCKED_RECIPES: unlocked_recipe_paths.duplicate(),
		SAVE_KEY_UNLOCKED_INGREDIENTS: unlocked_ingredient_ids.duplicate(),
		SAVE_KEY_GAME_VERSION: GAME_VERSION,
	}


func apply_save_data(save_data: Dictionary) -> void:
	var saved_coins: int = int(save_data.get("coins", STARTING_COINS))
	var saved_gems: int = int(save_data.get("gems", STARTING_GEMS))
	set_currency(saved_coins, saved_gems)
	_apply_purchased_upgrade_save_ids(save_data.get(SAVE_KEY_PURCHASED_UPGRADES, []))
	_apply_unlocked_recipe_paths(save_data.get(SAVE_KEY_UNLOCKED_RECIPES, DEFAULT_UNLOCKED_RECIPE_PATHS))
	_apply_unlocked_ingredient_ids(save_data.get(SAVE_KEY_UNLOCKED_INGREDIENTS, []))
	_apply_grill_level_save_data(save_data)


func _get_purchased_upgrade_save_ids() -> Array[String]:
	var save_ids: Array[String] = []
	for upgrade_id: StringName in purchased_upgrade_ids:
		save_ids.append(String(upgrade_id))

	return save_ids


func _apply_purchased_upgrade_save_ids(saved_upgrade_ids: Variant) -> void:
	purchased_upgrade_ids.clear()
	if not saved_upgrade_ids is Array:
		upgrades_changed.emit()
		return

	for saved_upgrade_id: Variant in saved_upgrade_ids:
		var upgrade_id: StringName = StringName(str(saved_upgrade_id))
		if upgrade_id.is_empty() or purchased_upgrade_ids.has(upgrade_id):
			continue

		purchased_upgrade_ids.append(upgrade_id)

	upgrades_changed.emit()


func _apply_grill_level_save_data(save_data: Dictionary) -> void:
	if save_data.has(SAVE_KEY_GRILL_LEVEL):
		set_grill_level(int(save_data.get(SAVE_KEY_GRILL_LEVEL, DEFAULT_GRILL_LEVEL)))
	elif not purchased_upgrade_ids.is_empty():
		set_grill_level(2)
	else:
		set_grill_level(DEFAULT_GRILL_LEVEL)


func _get_grill_level_multiplier(level: int) -> float:
	var level_data: Dictionary = _get_grill_level_data(level)
	return float(level_data.get("cooking_speed_multiplier", DEFAULT_COOKING_SPEED_MULTIPLIER))


func _get_grill_level_data(level: int) -> Dictionary:
	return GRILL_LEVEL_DATA.get(clampi(level, DEFAULT_GRILL_LEVEL, MAX_GRILL_LEVEL), {})


func unlock_recipe(recipe_path: String) -> bool:
	if recipe_path.is_empty() or unlocked_recipe_paths.has(recipe_path):
		return false

	unlocked_recipe_paths.append(recipe_path)
	recipes_changed.emit()
	SaveManager.queue_save_game()
	return true


func get_unlocked_recipes() -> Array[Recipe]:
	var recipes: Array[Recipe] = []
	for recipe_path: String in unlocked_recipe_paths:
		var recipe: Resource = load(recipe_path)
		if recipe is Recipe:
			recipes.append(recipe as Recipe)

	return recipes


func _apply_unlocked_recipe_paths(saved_recipe_paths: Variant) -> void:
	unlocked_recipe_paths.clear()
	if saved_recipe_paths is Array:
		for saved_recipe_path: Variant in saved_recipe_paths:
			var recipe_path: String = str(saved_recipe_path)
			if recipe_path.is_empty() or unlocked_recipe_paths.has(recipe_path):
				continue

			unlocked_recipe_paths.append(recipe_path)

	if unlocked_recipe_paths.is_empty():
		unlocked_recipe_paths = DEFAULT_UNLOCKED_RECIPE_PATHS.duplicate()

	recipes_changed.emit()


func _apply_unlocked_ingredient_ids(saved_ingredient_ids: Variant) -> void:
	unlocked_ingredient_ids.clear()
	if not saved_ingredient_ids is Array:
		return

	for saved_ingredient_id: Variant in saved_ingredient_ids:
		var ingredient_id: String = str(saved_ingredient_id)
		if ingredient_id.is_empty() or unlocked_ingredient_ids.has(ingredient_id):
			continue

		unlocked_ingredient_ids.append(ingredient_id)
