extends Node

signal currency_changed(coins: int, gems: int)
signal upgrades_changed

const STARTING_COINS: int = 0
const STARTING_GEMS: int = 0
const DEFAULT_COOKING_SPEED_MULTIPLIER: float = 1.0
const SAVE_KEY_PURCHASED_UPGRADES: String = "purchased_upgrades"
const BETTER_GRILL_UPGRADE: UpgradeData = preload("res://Resources/Upgrades/BetterGrill.tres")

var coins: int = STARTING_COINS
var gems: int = STARTING_GEMS
var purchased_upgrade_ids: Array[StringName] = []
var cooking_speed_multiplier: float = DEFAULT_COOKING_SPEED_MULTIPLIER


func add_coins(amount: int) -> void:
	if amount <= 0:
		return

	set_currency(coins + amount, gems)


func spend_coins(amount: int) -> bool:
	if amount <= 0 or coins < amount:
		return false

	set_currency(coins - amount, gems)
	return true


func purchase_upgrade(upgrade: UpgradeData) -> bool:
	if upgrade == null or has_upgrade(upgrade.id):
		return false

	if not spend_coins(upgrade.cost):
		return false

	purchased_upgrade_ids.append(upgrade.id)
	cooking_speed_multiplier += upgrade.cooking_speed_multiplier_bonus
	upgrades_changed.emit()
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
		SAVE_KEY_PURCHASED_UPGRADES: _get_purchased_upgrade_save_ids(),
	}


func apply_save_data(save_data: Dictionary) -> void:
	var saved_coins: int = int(save_data.get("coins", STARTING_COINS))
	var saved_gems: int = int(save_data.get("gems", STARTING_GEMS))
	set_currency(saved_coins, saved_gems)
	_apply_purchased_upgrade_save_ids(save_data.get(SAVE_KEY_PURCHASED_UPGRADES, []))


func _get_purchased_upgrade_save_ids() -> Array[String]:
	var save_ids: Array[String] = []
	for upgrade_id: StringName in purchased_upgrade_ids:
		save_ids.append(String(upgrade_id))

	return save_ids


func _apply_purchased_upgrade_save_ids(saved_upgrade_ids: Variant) -> void:
	purchased_upgrade_ids.clear()
	cooking_speed_multiplier = DEFAULT_COOKING_SPEED_MULTIPLIER
	if not saved_upgrade_ids is Array:
		upgrades_changed.emit()
		return

	for saved_upgrade_id: Variant in saved_upgrade_ids:
		var upgrade_id: StringName = StringName(str(saved_upgrade_id))
		if upgrade_id.is_empty() or purchased_upgrade_ids.has(upgrade_id):
			continue

		purchased_upgrade_ids.append(upgrade_id)
		var upgrade: UpgradeData = _get_upgrade_data(upgrade_id)
		if upgrade != null:
			cooking_speed_multiplier += upgrade.cooking_speed_multiplier_bonus

	upgrades_changed.emit()


func _get_upgrade_data(upgrade_id: StringName) -> UpgradeData:
	if upgrade_id == BETTER_GRILL_UPGRADE.id:
		return BETTER_GRILL_UPGRADE

	return null
