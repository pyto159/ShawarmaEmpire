extends Node

signal kiosk_upgrades_changed
signal kiosk_upgrade_purchased(upgrade_id: StringName)

const BETTER_COUNTER_ID: StringName = &"better_counter"
const NEW_SIGN_ID: StringName = &"new_sign"
const BETTER_LIGHTING_ID: StringName = &"better_lighting"
const DECORATIONS_ID: StringName = &"decorations"
const SAVE_KEY_PURCHASED_KIOSK_UPGRADES: String = "purchased_kiosk_upgrades"
const DEFAULT_PATIENCE_MULTIPLIER: float = 1.0
const DEFAULT_SPAWN_RATE_MULTIPLIER: float = 1.0
const DEFAULT_RARE_ORDER_CHANCE_BONUS: float = 0.0
const DEFAULT_TIP_CHANCE_BONUS: float = 0.0
const DEFAULT_TIP_REWARD_MULTIPLIER: float = 0.20

var purchased_upgrade_ids: Array[StringName] = []


func reset_to_defaults() -> void:
	purchased_upgrade_ids.clear()
	kiosk_upgrades_changed.emit()


func get_available_upgrades() -> Array[Dictionary]:
	var available_upgrades: Array[Dictionary] = []
	for upgrade: Dictionary in get_all_upgrades():
		if not is_purchased(StringName(str(upgrade.get("id", "")))):
			available_upgrades.append(upgrade)

	return available_upgrades


func get_purchased_upgrades() -> Array[Dictionary]:
	var purchased_upgrades: Array[Dictionary] = []
	for upgrade: Dictionary in get_all_upgrades():
		if is_purchased(StringName(str(upgrade.get("id", "")))):
			purchased_upgrades.append(upgrade)

	return purchased_upgrades


func get_all_upgrades() -> Array[Dictionary]:
	return GameManager.economy_config.get_kiosk_upgrades()


func is_purchased(upgrade_id: StringName) -> bool:
	return purchased_upgrade_ids.has(upgrade_id)


func can_purchase(upgrade_id: StringName) -> bool:
	if is_purchased(upgrade_id):
		return false

	return GameManager.coins >= get_upgrade_cost(upgrade_id)


func purchase(upgrade_id: StringName) -> bool:
	if String(upgrade_id).is_empty() or is_purchased(upgrade_id):
		return false

	var cost: int = get_upgrade_cost(upgrade_id)
	if not GameManager.spend_coins(cost):
		return false

	purchased_upgrade_ids.append(upgrade_id)
	kiosk_upgrade_purchased.emit(upgrade_id)
	kiosk_upgrades_changed.emit()
	SaveManager.queue_save_game()
	return true


func get_upgrade_cost(upgrade_id: StringName) -> int:
	return int(_get_upgrade_data(upgrade_id).get("cost", 0))


func get_customer_patience_multiplier() -> float:
	return DEFAULT_PATIENCE_MULTIPLIER + _get_bonus_value(BETTER_COUNTER_ID, "customer_patience_bonus")


func get_customer_spawn_rate_multiplier() -> float:
	return DEFAULT_SPAWN_RATE_MULTIPLIER + _get_bonus_value(NEW_SIGN_ID, "customer_spawn_rate_bonus")


func get_rare_order_chance_bonus() -> float:
	return DEFAULT_RARE_ORDER_CHANCE_BONUS + _get_bonus_value(BETTER_LIGHTING_ID, "rare_order_chance_bonus")


func get_tip_chance_bonus() -> float:
	return DEFAULT_TIP_CHANCE_BONUS + _get_bonus_value(DECORATIONS_ID, "tip_chance_bonus")


func get_tip_reward_multiplier() -> float:
	return DEFAULT_TIP_REWARD_MULTIPLIER


func get_save_data() -> Array[String]:
	var save_ids: Array[String] = []
	for upgrade_id: StringName in purchased_upgrade_ids:
		save_ids.append(String(upgrade_id))

	return save_ids


func apply_save_data(saved_upgrade_ids: Variant) -> void:
	purchased_upgrade_ids.clear()
	if not saved_upgrade_ids is Array:
		kiosk_upgrades_changed.emit()
		return

	for saved_upgrade_id: Variant in saved_upgrade_ids:
		var upgrade_id: StringName = StringName(str(saved_upgrade_id))
		if String(upgrade_id).is_empty() or purchased_upgrade_ids.has(upgrade_id):
			continue
		if _get_upgrade_data(upgrade_id).is_empty():
			continue

		purchased_upgrade_ids.append(upgrade_id)

	kiosk_upgrades_changed.emit()


func _get_upgrade_data(upgrade_id: StringName) -> Dictionary:
	for upgrade: Dictionary in get_all_upgrades():
		if StringName(str(upgrade.get("id", ""))) == upgrade_id:
			return upgrade

	return {}


func _get_bonus_value(upgrade_id: StringName, bonus_key: String) -> float:
	if not is_purchased(upgrade_id):
		return 0.0

	return float(_get_upgrade_data(upgrade_id).get(bonus_key, 0.0))
