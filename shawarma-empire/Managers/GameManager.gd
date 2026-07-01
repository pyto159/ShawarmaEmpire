extends Node

signal currency_changed(coins: int, gems: int)

const STARTING_COINS: int = 0
const STARTING_GEMS: int = 0

var coins: int = STARTING_COINS
var gems: int = STARTING_GEMS


func add_coins(amount: int) -> void:
	if amount <= 0:
		return

	set_currency(coins + amount, gems)


func set_currency(new_coins: int, new_gems: int) -> void:
	coins = max(new_coins, 0)
	gems = max(new_gems, 0)
	currency_changed.emit(coins, gems)


func get_save_data() -> Dictionary:
	return {
		"coins": coins,
		"gems": gems,
	}


func apply_save_data(save_data: Dictionary) -> void:
	var saved_coins: int = int(save_data.get("coins", STARTING_COINS))
	var saved_gems: int = int(save_data.get("gems", STARTING_GEMS))
	set_currency(saved_coins, saved_gems)
