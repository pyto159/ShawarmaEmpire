extends Node

signal currency_changed(coins: int, gems: int)
signal upgrades_changed
signal grill_upgraded(level: int, speed_improvement_percent: int)
signal recipes_changed
signal combo_changed(combo_level: int)

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
const SAVE_KEY_REPUTATION: String = "reputation"
const SAVE_KEY_BUSINESS_LEVEL: String = "business_level"
const SAVE_KEY_GAME_VERSION: String = "game_version"
const GAME_VERSION: String = "0.8.0"
const FAVORITE_RECIPE_REWARD_MULTIPLIER: float = 1.25
const DEFAULT_COMBO_LEVEL: int = 0
const REWARD_BASE_KEY: String = "base_coins"
const REWARD_TIP_KEY: String = "tip_coins"
const REWARD_COMBO_BONUS_KEY: String = "combo_bonus_coins"
const REWARD_RARE_BONUS_KEY: String = "rare_bonus_coins"
const REWARD_FAVORITE_BONUS_KEY: String = "favorite_bonus_coins"
const REWARD_TOTAL_KEY: String = "total_coins"
const REWARD_COMBO_LEVEL_KEY: String = "combo_level"
const REWARD_COMBO_INCREASED_KEY: String = "combo_increased"
var coins: int = STARTING_COINS
var gems: int = STARTING_GEMS
var purchased_upgrade_ids: Array[StringName] = []
var grill_level: int = DEFAULT_GRILL_LEVEL
var cooking_speed_multiplier: float = DEFAULT_COOKING_SPEED_MULTIPLIER
var economy_config: EconomyConfig = EconomyConfig.load_or_default(ECONOMY_CONFIG_PATH)
var combo_level: int = DEFAULT_COMBO_LEVEL


func initialize_new_game() -> void:
	set_currency(STARTING_COINS, STARTING_GEMS)
	purchased_upgrade_ids.clear()
	IngredientManager.reset_to_defaults()
	KioskUpgradeManager.reset_to_defaults()
	ReputationManager.reset_to_defaults()
	set_grill_level(DEFAULT_GRILL_LEVEL)
	reset_combo()
	recipes_changed.emit()


func calculate_order_reward(order: Order, customer: Customer = null) -> int:
	return calculate_order_reward_details(order, customer).get(REWARD_TOTAL_KEY, 0)


func calculate_order_reward_details(order: Order, customer: Customer = null) -> Dictionary:
	if order == null:
		return _create_empty_reward_details(false)

	var combo_increased: bool = increase_combo()
	var base_coins: int = max(order.total_price, 0)
	var rare_bonus_coins: int = _calculate_rare_bonus(base_coins, order.reward_multiplier)
	var favorite_bonus_coins: int = _calculate_favorite_bonus(base_coins, customer, order)
	var combo_bonus_coins: int = roundi(float(base_coins) * economy_config.get_combo_bonus_percent(combo_level))
	var tip_coins: int = _roll_tip_coins(base_coins)
	var total_coins: int = base_coins + rare_bonus_coins + favorite_bonus_coins + combo_bonus_coins + tip_coins

	return {
		REWARD_BASE_KEY: base_coins,
		REWARD_TIP_KEY: tip_coins,
		REWARD_COMBO_BONUS_KEY: combo_bonus_coins,
		REWARD_RARE_BONUS_KEY: rare_bonus_coins,
		REWARD_FAVORITE_BONUS_KEY: favorite_bonus_coins,
		REWARD_TOTAL_KEY: total_coins,
		REWARD_COMBO_LEVEL_KEY: combo_level,
		REWARD_COMBO_INCREASED_KEY: combo_increased,
	}


func increase_combo() -> bool:
	var previous_combo: int = combo_level
	combo_level = clampi(combo_level + 1, DEFAULT_COMBO_LEVEL, economy_config.get_max_combo_level())
	combo_changed.emit(combo_level)
	return combo_level > previous_combo


func reset_combo() -> void:
	if combo_level == DEFAULT_COMBO_LEVEL:
		combo_changed.emit(combo_level)
		return

	combo_level = DEFAULT_COMBO_LEVEL
	combo_changed.emit(combo_level)


func add_coins(amount: int) -> void:
	if amount <= 0:
		return

	set_currency(coins + amount, gems)


func set_coins(amount: int) -> void:
	set_currency(amount, gems)
	SaveManager.queue_save_game()


func add_dev_coins(amount: int) -> void:
	if amount <= 0:
		return

	add_coins(amount)
	SaveManager.queue_save_game()


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


func set_grill_level_for_testing(level: int) -> void:
	set_grill_level(level)
	SaveManager.queue_save_game()


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
		SAVE_KEY_REPUTATION: ReputationManager.reputation,
		SAVE_KEY_BUSINESS_LEVEL: ReputationManager.business_level,
		SAVE_KEY_GAME_VERSION: GAME_VERSION,
	}


func apply_save_data(save_data: Dictionary) -> void:
	var saved_coins: int = int(save_data.get("coins", STARTING_COINS))
	var saved_gems: int = int(save_data.get("gems", STARTING_GEMS))
	set_currency(saved_coins, saved_gems)
	_apply_purchased_upgrade_save_ids(save_data.get(SAVE_KEY_PURCHASED_UPGRADES, []))
	IngredientManager.apply_unlocked_ingredient_ids(save_data.get(SAVE_KEY_UNLOCKED_INGREDIENTS, []))
	KioskUpgradeManager.apply_save_data(save_data.get(SAVE_KEY_PURCHASED_KIOSK_UPGRADES, []))
	ReputationManager.apply_save_data(save_data.get(SAVE_KEY_REPUTATION, ReputationManager.STARTING_REPUTATION), save_data.get(SAVE_KEY_BUSINESS_LEVEL, ReputationManager.STARTING_BUSINESS_LEVEL))
	_apply_grill_level_save_data(save_data)
	reset_combo()


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


func _create_empty_reward_details(combo_increased: bool) -> Dictionary:
	return {
		REWARD_BASE_KEY: 0,
		REWARD_TIP_KEY: 0,
		REWARD_COMBO_BONUS_KEY: 0,
		REWARD_RARE_BONUS_KEY: 0,
		REWARD_FAVORITE_BONUS_KEY: 0,
		REWARD_TOTAL_KEY: 0,
		REWARD_COMBO_LEVEL_KEY: combo_level,
		REWARD_COMBO_INCREASED_KEY: combo_increased,
	}


func _calculate_rare_bonus(base_coins: int, reward_multiplier: float) -> int:
	var bonus_multiplier: float = max(reward_multiplier, Order.DEFAULT_REWARD_MULTIPLIER) - Order.DEFAULT_REWARD_MULTIPLIER
	return roundi(float(base_coins) * max(bonus_multiplier, 0.0))


func _calculate_favorite_bonus(base_coins: int, customer: Customer, order: Order) -> int:
	if customer == null or not customer.is_favorite_order(order):
		return 0

	return roundi(float(base_coins) * (FAVORITE_RECIPE_REWARD_MULTIPLIER - 1.0))


func _roll_tip_coins(base_coins: int) -> int:
	var total_tip_chance: float = clampf(economy_config.get_tip_chance() + KioskUpgradeManager.get_tip_chance_bonus(), 0.0, 1.0)
	if base_coins <= 0 or randf() >= total_tip_chance:
		return 0

	var tip_percent: float = randf_range(economy_config.get_tip_min_percent(), economy_config.get_tip_max_percent())
	return maxi(roundi(float(base_coins) * tip_percent), 1)


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
