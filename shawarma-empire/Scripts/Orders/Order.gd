extends Resource
class_name Order

signal completed(order: Order)

const DEFAULT_TOTAL_PRICE: int = 0
const DEFAULT_PREPARATION_TIME: float = 0.0
const DEFAULT_CREATION_TIME: float = 0.0
const DEFAULT_COMPLETION_TIME: float = 0.0
const MILLISECONDS_PER_SECOND: float = 1000.0
const ECONOMY_CONFIG_PATH: String = "res://Resources/Economy/EconomyConfig.tres"

@export var selected_recipe: Recipe
@export var total_price: int = DEFAULT_TOTAL_PRICE
@export var preparation_time: float = DEFAULT_PREPARATION_TIME
@export var creation_time: float = DEFAULT_CREATION_TIME
@export var completion_time: float = DEFAULT_COMPLETION_TIME
@export var is_completed: bool = false


static func create(recipe: Recipe, order_creation_time: float) -> Order:
	var order: Order = Order.new()
	order.selected_recipe = recipe
	if recipe != null:
		var economy_config: EconomyConfig = EconomyConfig.load_or_default(ECONOMY_CONFIG_PATH)
		order.total_price = economy_config.get_recipe_reward(recipe)
		order.preparation_time = economy_config.get_recipe_preparation_time(recipe)
	order.creation_time = order_creation_time
	return order


func complete(order_completion_time: float = DEFAULT_COMPLETION_TIME) -> bool:
	if is_completed:
		return false

	is_completed = true
	completion_time = _resolve_completion_time(order_completion_time)
	completed.emit(self)
	return true


func _resolve_completion_time(order_completion_time: float) -> float:
	if order_completion_time > DEFAULT_COMPLETION_TIME:
		return order_completion_time

	return float(Time.get_ticks_msec()) / MILLISECONDS_PER_SECOND
