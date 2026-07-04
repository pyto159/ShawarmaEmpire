extends Node

signal ingredient_unlocked(ingredient_id: String)
signal ingredients_changed

const INGREDIENT_ID_LAVASH: String = "lavash"
const INGREDIENT_ID_CHICKEN: String = "chicken"
const INGREDIENT_ID_GARLIC_SAUCE: String = "garlic_sauce"
const INGREDIENT_ID_TOMATO: String = "tomato"
const INGREDIENT_ID_CUCUMBER: String = "cucumber"
const INGREDIENT_ID_JALAPENO: String = "jalapeno"
const INGREDIENT_ID_SPICY_SAUCE: String = "spicy_sauce"
const INGREDIENT_ID_CHEESE: String = "cheese"
const CLASSIC_SHAWARMA_PATH: String = "res://Resources/Recipes/ClassicShawarma.tres"
const SPICY_SHAWARMA_PATH: String = "res://Resources/Recipes/SpicyShawarma.tres"
const CHEESE_SHAWARMA_PATH: String = "res://Resources/Recipes/CheeseShawarma.tres"
const ECONOMY_CONFIG_PATH: String = "res://Resources/Economy/EconomyConfig.tres"
const DEFAULT_UNLOCKED_INGREDIENT_IDS: Array[String] = [
	INGREDIENT_ID_LAVASH,
	INGREDIENT_ID_CHICKEN,
	INGREDIENT_ID_GARLIC_SAUCE,
	INGREDIENT_ID_TOMATO,
	INGREDIENT_ID_CUCUMBER,
]
const INGREDIENT_DEFINITIONS: Dictionary = {
	INGREDIENT_ID_LAVASH: {"display_name": "Lavash"},
	INGREDIENT_ID_CHICKEN: {"display_name": "Chicken"},
	INGREDIENT_ID_GARLIC_SAUCE: {"display_name": "Garlic Sauce"},
	INGREDIENT_ID_TOMATO: {"display_name": "Tomato"},
	INGREDIENT_ID_CUCUMBER: {"display_name": "Cucumber"},
	INGREDIENT_ID_JALAPENO: {"display_name": "Jalapeño"},
	INGREDIENT_ID_SPICY_SAUCE: {"display_name": "Spicy Sauce"},
	INGREDIENT_ID_CHEESE: {"display_name": "Cheese"},
}
const INGREDIENT_UNLOCK_ORDER: Array[String] = [
	INGREDIENT_ID_JALAPENO,
	INGREDIENT_ID_SPICY_SAUCE,
	INGREDIENT_ID_CHEESE,
]
const RECIPE_PATHS: Array[String] = [
	CLASSIC_SHAWARMA_PATH,
	SPICY_SHAWARMA_PATH,
	CHEESE_SHAWARMA_PATH,
]

var unlocked_ingredient_ids: Array[String] = DEFAULT_UNLOCKED_INGREDIENT_IDS.duplicate()
var economy_config: EconomyConfig = EconomyConfig.load_or_default(ECONOMY_CONFIG_PATH)


func reset_to_defaults() -> void:
	unlocked_ingredient_ids = DEFAULT_UNLOCKED_INGREDIENT_IDS.duplicate()
	ingredients_changed.emit()


func is_unlocked(ingredient_id: String) -> bool:
	return unlocked_ingredient_ids.has(ingredient_id)


func can_unlock(ingredient_id: String) -> bool:
	return _has_ingredient_definition(ingredient_id) and not is_unlocked(ingredient_id) and GameManager.coins >= get_unlock_cost(ingredient_id)


func unlock_ingredient(ingredient_id: String) -> bool:
	if not can_unlock(ingredient_id):
		return false

	if not GameManager.spend_coins(get_unlock_cost(ingredient_id)):
		return false

	unlocked_ingredient_ids.append(ingredient_id)
	ingredient_unlocked.emit(ingredient_id)
	ingredients_changed.emit()
	GameManager.recipes_changed.emit()
	SaveManager.queue_save_game()
	return true


func apply_unlocked_ingredient_ids(saved_ingredient_ids: Variant) -> void:
	unlocked_ingredient_ids.clear()
	for default_ingredient_id: String in DEFAULT_UNLOCKED_INGREDIENT_IDS:
		unlocked_ingredient_ids.append(default_ingredient_id)

	if saved_ingredient_ids is Array:
		for saved_ingredient_id: Variant in saved_ingredient_ids:
			var ingredient_id: String = str(saved_ingredient_id)
			if not _has_ingredient_definition(ingredient_id) or unlocked_ingredient_ids.has(ingredient_id):
				continue

			unlocked_ingredient_ids.append(ingredient_id)

	ingredients_changed.emit()
	GameManager.recipes_changed.emit()


func get_unlocked_ingredient_ids() -> Array[String]:
	return unlocked_ingredient_ids.duplicate()


func get_next_locked_ingredient_id() -> String:
	for ingredient_id: String in INGREDIENT_UNLOCK_ORDER:
		if not is_unlocked(ingredient_id):
			return ingredient_id

	return ""


func get_display_name(ingredient_id: String) -> String:
	var ingredient_data: Dictionary = _get_ingredient_data(ingredient_id)
	return str(ingredient_data.get("display_name", ingredient_id.capitalize()))


func get_unlock_cost(ingredient_id: String) -> int:
	return economy_config.get_ingredient_cost(ingredient_id)


func get_available_recipes() -> Array[Recipe]:
	var available_recipes: Array[Recipe] = []
	for recipe_path: String in RECIPE_PATHS:
		var recipe: Resource = load(recipe_path)
		if recipe is Recipe and _is_recipe_available(recipe as Recipe):
			available_recipes.append(recipe as Recipe)

	if available_recipes.is_empty():
		var classic_recipe: Recipe = load(CLASSIC_SHAWARMA_PATH) as Recipe
		if classic_recipe != null:
			available_recipes.append(classic_recipe)

	return available_recipes


func _is_recipe_available(recipe: Recipe) -> bool:
	for ingredient: Ingredient in recipe.required_ingredients:
		if ingredient == null or not is_unlocked(ingredient.id):
			return false

	return true


func _has_ingredient_definition(ingredient_id: String) -> bool:
	return INGREDIENT_DEFINITIONS.has(ingredient_id)


func _get_ingredient_data(ingredient_id: String) -> Dictionary:
	return INGREDIENT_DEFINITIONS.get(ingredient_id, {})
