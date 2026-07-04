extends RefCounted
class_name OrderGenerator

const MILLISECONDS_PER_SECOND: float = 1000.0
const CLASSIC_SHAWARMA_PATH: String = "res://Resources/Recipes/ClassicShawarma.tres"


func generate_order(available_recipes: Array[Recipe]) -> Order:
	var recipe_options: Array[Recipe] = available_recipes.duplicate()
	if recipe_options.is_empty():
		var fallback_recipe: Recipe = load(CLASSIC_SHAWARMA_PATH) as Recipe
		if fallback_recipe == null:
			push_error("OrderGenerator could not load the Classic Shawarma fallback recipe.")
			return null

		recipe_options.append(fallback_recipe)

	var recipe_index: int = randi_range(0, recipe_options.size() - 1)
	var selected_recipe: Recipe = recipe_options[recipe_index]
	return Order.create(selected_recipe, _get_current_time())


func _get_current_time() -> float:
	return float(Time.get_ticks_msec()) / MILLISECONDS_PER_SECOND
