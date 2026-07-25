extends Node

signal kiosk_upgrades_changed
signal kiosk_upgrade_purchased(upgrade_id: StringName, level: int)

const BETTER_COUNTER_ID: StringName = &"better_counter"
const DEFAULT_UPGRADE_LEVEL: int = 1

var upgrade_levels: Dictionary = {}


func reset_to_defaults() -> void:
	upgrade_levels.clear()
	kiosk_upgrades_changed.emit()


func get_upgrade_level(upgrade_id: StringName) -> int:
	return int(upgrade_levels.get(upgrade_id, DEFAULT_UPGRADE_LEVEL))


func get_next_upgrade_cost(upgrade_id: StringName) -> int:
	return GameManager.economy_config.get_upgrade_cost(upgrade_id, get_upgrade_level(upgrade_id) + 1)


func is_upgrade_maxed(upgrade_id: StringName) -> bool:
	return get_upgrade_level(upgrade_id) >= GameManager.economy_config.get_upgrade_max_level(upgrade_id)


func can_purchase_upgrade(upgrade_id: StringName) -> bool:
	if not GameManager.economy_config.has_kiosk_upgrade(upgrade_id) or is_upgrade_maxed(upgrade_id):
		return false
	return GameManager.coins >= get_next_upgrade_cost(upgrade_id)


func purchase_upgrade(upgrade_id: StringName) -> bool:
	if not can_purchase_upgrade(upgrade_id):
		return false

	var cost: int = get_next_upgrade_cost(upgrade_id)
	if not GameManager.spend_coins(cost):
		return false

	var new_level: int = get_upgrade_level(upgrade_id) + 1
	upgrade_levels[upgrade_id] = new_level
	kiosk_upgrade_purchased.emit(upgrade_id, new_level)
	kiosk_upgrades_changed.emit()
	SaveManager.queue_save_game()
	return true


func get_upgrade_effect(upgrade_id: StringName) -> float:
	return GameManager.economy_config.get_upgrade_effect(upgrade_id, get_upgrade_level(upgrade_id))


func get_order_income_multiplier() -> float:
	return get_upgrade_effect(BETTER_COUNTER_ID)


func set_upgrade_level_for_testing(upgrade_id: StringName, level: int) -> void:
	if not GameManager.economy_config.has_kiosk_upgrade(upgrade_id):
		return
	upgrade_levels[upgrade_id] = clampi(level, DEFAULT_UPGRADE_LEVEL, GameManager.economy_config.get_upgrade_max_level(upgrade_id))
	kiosk_upgrades_changed.emit()
	SaveManager.queue_save_game()


func get_save_data() -> Dictionary:
	var save_data: Dictionary = {}
	for upgrade_id: StringName in GameManager.economy_config.get_kiosk_upgrade_ids():
		save_data[String(upgrade_id)] = get_upgrade_level(upgrade_id)
	return save_data


func apply_save_data(saved_levels: Variant) -> void:
	upgrade_levels.clear()
	if saved_levels is Dictionary:
		for upgrade_id: StringName in GameManager.economy_config.get_kiosk_upgrade_ids():
			var max_level: int = GameManager.economy_config.get_upgrade_max_level(upgrade_id)
			upgrade_levels[upgrade_id] = clampi(int(saved_levels.get(String(upgrade_id), DEFAULT_UPGRADE_LEVEL)), DEFAULT_UPGRADE_LEVEL, max_level)
	kiosk_upgrades_changed.emit()
