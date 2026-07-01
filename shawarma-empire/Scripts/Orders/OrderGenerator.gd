extends RefCounted
class_name OrderGenerator

const MILLISECONDS_PER_SECOND: float = 1000.0


func generate_order(available_recipes: Array[Recipe]) -> Order:
	if available_recipes.is_empty():
		push_error("OrderGenerator requires at least one available recipe.")
		return null

	var recipe_index: int = randi_range(0, available_recipes.size() - 1)
	var selected_recipe: Recipe = available_recipes[recipe_index]
	return Order.create(selected_recipe, _get_current_time())


func _get_current_time() -> float:
	return float(Time.get_ticks_msec()) / MILLISECONDS_PER_SECOND
