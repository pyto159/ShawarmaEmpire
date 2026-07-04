extends Resource
class_name Recipe

const DEFAULT_PREPARATION_TIME: float = 1.0

@export var display_name: String = ""
@export var preparation_time: float = DEFAULT_PREPARATION_TIME
@export var required_ingredients: Array[Ingredient] = []
