extends Node

signal reputation_changed(reputation: int, business_level: int, amount_added: int)
signal business_level_changed(business_level: int)

const STARTING_REPUTATION: int = 0
const STARTING_BUSINESS_LEVEL: int = 1
const REPUTATION_PER_SERVED_CUSTOMER: int = 1
const RARE_ORDER_REPUTATION_BONUS: int = 2
const FAVORITE_RECIPE_REPUTATION_BONUS: int = 2
const LEVEL_2_REPUTATION: int = 25
const LEVEL_3_REPUTATION: int = 75
const LEVEL_4_REPUTATION: int = 150
const LEVEL_5_REPUTATION: int = 300
const LEVEL_2_QUEUE_SLOT_BONUS: int = 1
const LEVEL_3_RARE_ORDER_CHANCE_BONUS: float = 0.05
const LEVEL_4_SPAWN_RATE_BONUS: float = 0.10
const DEFAULT_QUEUE_SLOT_BONUS: int = 0
const DEFAULT_RARE_ORDER_CHANCE_BONUS: float = 0.0
const DEFAULT_SPAWN_RATE_MULTIPLIER: float = 1.0

var reputation: int = STARTING_REPUTATION
var business_level: int = STARTING_BUSINESS_LEVEL


func reset_to_defaults() -> void:
	reputation = STARTING_REPUTATION
	business_level = STARTING_BUSINESS_LEVEL
	reputation_changed.emit(reputation, business_level, 0)


func add_reputation(amount: int) -> void:
	if amount <= 0:
		return

	var previous_level: int = business_level
	reputation += amount
	business_level = get_business_level_for_reputation(reputation)
	reputation_changed.emit(reputation, business_level, amount)
	if business_level > previous_level:
		business_level_changed.emit(business_level)
	SaveManager.queue_save_game()


func add_order_reputation(order: Order, customer: Customer) -> int:
	if order == null:
		return 0

	var amount: int = REPUTATION_PER_SERVED_CUSTOMER
	if order.is_rare:
		amount += RARE_ORDER_REPUTATION_BONUS
	if customer != null and customer.is_favorite_order(order):
		amount += FAVORITE_RECIPE_REPUTATION_BONUS
	add_reputation(amount)
	return amount


func apply_save_data(saved_reputation: Variant, _saved_business_level: Variant) -> void:
	reputation = max(int(saved_reputation), STARTING_REPUTATION)
	business_level = get_business_level_for_reputation(reputation)
	reputation_changed.emit(reputation, business_level, 0)


func get_business_level_for_reputation(value: int) -> int:
	if value >= LEVEL_5_REPUTATION:
		return 5
	if value >= LEVEL_4_REPUTATION:
		return 4
	if value >= LEVEL_3_REPUTATION:
		return 3
	if value >= LEVEL_2_REPUTATION:
		return 2
	return STARTING_BUSINESS_LEVEL


func get_queue_slot_bonus() -> int:
	if business_level >= 2:
		return LEVEL_2_QUEUE_SLOT_BONUS
	return DEFAULT_QUEUE_SLOT_BONUS


func get_rare_order_chance_bonus() -> float:
	if business_level >= 3:
		return LEVEL_3_RARE_ORDER_CHANCE_BONUS
	return DEFAULT_RARE_ORDER_CHANCE_BONUS


func get_customer_spawn_rate_multiplier() -> float:
	if business_level >= 4:
		return DEFAULT_SPAWN_RATE_MULTIPLIER + LEVEL_4_SPAWN_RATE_BONUS
	return DEFAULT_SPAWN_RATE_MULTIPLIER


func has_future_content_hook() -> bool:
	return business_level >= 5
