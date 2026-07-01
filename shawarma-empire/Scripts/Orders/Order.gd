extends Resource
class_name Order

const DEFAULT_TOTAL_PRICE: int = 0
const DEFAULT_PREPARATION_TIME: float = 0.0
const DEFAULT_CREATION_TIME: float = 0.0

@export var selected_recipe: Recipe
@export var total_price: int = DEFAULT_TOTAL_PRICE
@export var preparation_time: float = DEFAULT_PREPARATION_TIME
@export var creation_time: float = DEFAULT_CREATION_TIME
@export var is_completed: bool = false


static func create(recipe: Recipe, order_creation_time: float) -> Order:
	var order: Order = Order.new()
	order.selected_recipe = recipe
	order.total_price = recipe.base_price
	order.preparation_time = recipe.preparation_time
	order.creation_time = order_creation_time
	return order


func complete() -> void:
	is_completed = true
