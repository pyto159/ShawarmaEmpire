extends Resource
class_name UpgradeData

const DEFAULT_COST: int = 0
const DEFAULT_COOKING_SPEED_MULTIPLIER_BONUS: float = 0.0

@export var id: StringName
@export var display_name: String = ""
@export var cost: int = DEFAULT_COST
@export var cooking_speed_multiplier_bonus: float = DEFAULT_COOKING_SPEED_MULTIPLIER_BONUS


func get_button_text() -> String:
	return "%s - %d Coins" % [display_name, cost]
