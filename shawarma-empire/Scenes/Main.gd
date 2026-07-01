extends Control

@onready var game_hud: GameHUD = $GameHUD
@onready var cooking_stand: CookingStand = $World/CookingStand
@onready var playable_customer: Customer = $World/PlayableCustomer


func _ready() -> void:
	SaveManager.load_game()
	game_hud.set_cooking_stand(cooking_stand)
	game_hud.set_active_customer(playable_customer)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		SaveManager.save_game()
