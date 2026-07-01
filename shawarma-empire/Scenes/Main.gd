extends Control

@onready var game_hud: GameHUD = $GameHUD
@onready var cooking_stand: CookingStand = $World/CookingStand
@onready var playable_customer: Customer = $World/PlayableCustomer


func _ready() -> void:
	SaveManager.load_game()
	_connect_cooking_stand()
	game_hud.set_cooking_stand(cooking_stand)
	game_hud.set_active_customer(playable_customer)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		SaveManager.save_game()


func _connect_cooking_stand() -> void:
	if not cooking_stand.cooking_completed.is_connected(_on_cooking_completed):
		cooking_stand.cooking_completed.connect(_on_cooking_completed)


func _on_cooking_completed(order: Order) -> void:
	if order == null:
		return

	if not order.is_completed:
		order.complete()

	GameManager.add_coins(order.total_price)
	game_hud.show_coin_feedback(order.total_price)
