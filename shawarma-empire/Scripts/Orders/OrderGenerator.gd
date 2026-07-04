extends RefCounted
class_name OrderGenerator

const MILLISECONDS_PER_SECOND: float = 1000.0
const CLASSIC_SHAWARMA_PATH: String = "res://Resources/Recipes/ClassicShawarma.tres"
const DEFAULT_RARE_ORDER_CHANCE: float = 0.10
const RARE_ORDER_REWARD_MULTIPLIER: float = 2.0
const RARE_ORDER_BONUS_LABEL: String = "Rare Order!"


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
	var is_rare_order: bool = randf() < DEFAULT_RARE_ORDER_CHANCE
	var reward_multiplier: float = RARE_ORDER_REWARD_MULTIPLIER if is_rare_order else Order.DEFAULT_REWARD_MULTIPLIER
	var bonus_label: String = RARE_ORDER_BONUS_LABEL if is_rare_order else Order.EMPTY_BONUS_LABEL
	return Order.create(selected_recipe, _get_current_time(), is_rare_order, reward_multiplier, bonus_label)


func _get_current_time() -> float:
	return float(Time.get_ticks_msec()) / MILLISECONDS_PER_SECOND
