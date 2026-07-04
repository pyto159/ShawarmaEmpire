extends Node

signal currency_changed(coins: int, gems: int)
signal upgrades_changed
signal grill_upgraded(level: int, speed_improvement_percent: int)
signal recipes_changed

const STARTING_COINS: int = 0
const STARTING_GEMS: int = 0
const DEFAULT_GRILL_LEVEL: int = 1
const DEFAULT_COOKING_SPEED_MULTIPLIER: float = EconomyConfig.DEFAULT_COOKING_SPEED_MULTIPLIER
const ECONOMY_CONFIG_PATH: String = "res://Resources/Economy/EconomyConfig.tres"
const SAVE_KEY_GRILL_LEVEL: String = "grill_level"
const SAVE_KEY_PURCHASED_UPGRADES: String = "purchased_upgrades"
const SAVE_KEY_UNLOCKED_RECIPES: String = "unlocked_recipes"
const SAVE_KEY_UNLOCKED_INGREDIENTS: String = "unlocked_ingredients"
const SAVE_KEY_PURCHASED_KIOSK_UPGRADES: String = "purchased_kiosk_upgrades"
const SAVE_KEY_GAME_VERSION: String = "game_version"
const GAME_VERSION: String = "0.8.0"
const FAVORITE_RECIPE_REWARD_MULTIPLIER: float = 1.25
var coins: int = STARTING_COINS
var gems: int = STARTING_GEMS
var purchased_upgrade_ids: Array[StringName] = []
var grill_level: int = DEFAULT_GRILL_LEVEL
var cooking_speed_multiplier: float = DEFAULT_COOKING_SPEED_MULTIPLIER
var economy_config: EconomyConfig = EconomyConfig.load_or_default(ECONOMY_CONFIG_PATH)


func initialize_new_game() -> void:
	set_currency(STARTING_COINS, STARTING_GEMS)
	purchased_upgrade_ids.clear()
	IngredientManager.reset_to_defaults()
	KioskUpgradeManager.reset_to_defaults()
	set_grill_level(DEFAULT_GRILL_LEVEL)
	recipes_changed.emit()


func calculate_order_reward(order: Order, customer: Customer = null) -> int:
	if order == null:
		return 0

	var final_reward: float = float(max(order.total_price, 0)) * max(order.reward_multiplier, Order.DEFAULT_REWARD_MULTIPLIER)
	if customer != null and customer.is_favorite_order(order):
		final_reward *= FAVORITE_RECIPE_REWARD_MULTIPLIER
	if randf() < KioskUpgradeManager.get_tip_chance_bonus():
		final_reward *= 1.0 + KioskUpgradeManager.get_tip_reward_multiplier()

	return roundi(final_reward)


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
	if next_level > economy_config.get_max_grill_level():
		return false

	var cost: int = get_grill_level_cost(next_level)
	if not spend_coins(cost):
		return false

	var previous_multiplier: float = cooking_speed_multiplier
	set_grill_level(next_level)
	grill_upgraded.emit(grill_level, _get_speed_improvement_percent(previous_multiplier, cooking_speed_multiplier))
	SaveManager.queue_save_game()
	return true


func get_next_grill_level() -> int:
	return grill_level + 1


func is_max_grill_level() -> bool:
	return grill_level >= economy_config.get_max_grill_level()


func get_grill_level_display_name(level: int = DEFAULT_GRILL_LEVEL) -> String:
	var display_level: int = level
	if display_level < DEFAULT_GRILL_LEVEL:
		display_level = grill_level

	return economy_config.get_grill_display_name(display_level)


func get_grill_level_cost(level: int) -> int:
	return economy_config.get_grill_cost(level)


func get_next_grill_button_text() -> String:
	if is_max_grill_level():
		return "MAX LEVEL\nLv. %d • %s" % [grill_level, get_grill_level_display_name(grill_level)]

	var next_level: int = get_next_grill_level()
	return "Lv. %d • %s\nNext: %s\nCost: %d Coins" % [
		grill_level,
		get_grill_level_display_name(grill_level),
		get_grill_level_display_name(next_level),
		get_grill_level_cost(next_level),
	]


func set_grill_level(level: int) -> void:
	grill_level = clampi(level, DEFAULT_GRILL_LEVEL, economy_config.get_max_grill_level())
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
		SAVE_KEY_UNLOCKED_RECIPES: _get_available_recipe_save_paths(),
		SAVE_KEY_UNLOCKED_INGREDIENTS: IngredientManager.get_unlocked_ingredient_ids(),
		SAVE_KEY_PURCHASED_KIOSK_UPGRADES: KioskUpgradeManager.get_save_data(),
		SAVE_KEY_GAME_VERSION: GAME_VERSION,
	}


func apply_save_data(save_data: Dictionary) -> void:
	var saved_coins: int = int(save_data.get("coins", STARTING_COINS))
	var saved_gems: int = int(save_data.get("gems", STARTING_GEMS))
	set_currency(saved_coins, saved_gems)
	_apply_purchased_upgrade_save_ids(save_data.get(SAVE_KEY_PURCHASED_UPGRADES, []))
	IngredientManager.apply_unlocked_ingredient_ids(save_data.get(SAVE_KEY_UNLOCKED_INGREDIENTS, []))
	KioskUpgradeManager.apply_save_data(save_data.get(SAVE_KEY_PURCHASED_KIOSK_UPGRADES, []))
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
	return economy_config.get_cooking_multiplier(level)


func _get_speed_improvement_percent(previous_multiplier: float, current_multiplier: float) -> int:
	if previous_multiplier <= 0.0 or current_multiplier >= previous_multiplier:
		return 0

	var speed_ratio: float = previous_multiplier / current_multiplier
	return roundi((speed_ratio - 1.0) * 100.0)


func unlock_recipe(_recipe_path: String) -> bool:
	return false


func get_unlocked_recipes() -> Array[Recipe]:
	return IngredientManager.get_available_recipes()


func _get_available_recipe_save_paths() -> Array[String]:
	var recipe_paths: Array[String] = []
	for recipe: Recipe in get_unlocked_recipes():
		if recipe.resource_path.is_empty():
			continue

		recipe_paths.append(recipe.resource_path)

	return recipe_paths
