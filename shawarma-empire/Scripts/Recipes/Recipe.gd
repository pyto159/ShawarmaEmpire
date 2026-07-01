extends Resource
class_name Recipe

const DEFAULT_BASE_PRICE: int = 0
const DEFAULT_PREPARATION_TIME: float = 1.0

@export var display_name: String = ""
@export var base_price: int = DEFAULT_BASE_PRICE
@export var preparation_time: float = DEFAULT_PREPARATION_TIME
@export var required_ingredients: Array[Ingredient] = []
