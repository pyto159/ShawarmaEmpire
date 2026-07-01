extends MarginContainer
class_name GameHUD

signal order_ready(order: Order)

const NO_ORDER_TEXT: String = "Order: Waiting"
const ORDER_PREFIX: String = "Order: "
const PREPARE_IDLE_TEXT: String = "Prepare"
const PREPARE_COOKING_TEXT: String = "Cooking..."
const UNKNOWN_RECIPE_TEXT: String = "Unknown Recipe"
const COINS_PREFIX: String = "Coins: "
const COOKING_STAND_NOT_FOUND: String = "Cooking stand was not found."
const COIN_FEEDBACK_PREFIX: String = "+"
const COIN_FEEDBACK_SUFFIX: String = " Coins"
const FEEDBACK_VISIBLE_SECONDS: float = 1.5

@export var cooking_stand_path: NodePath
@export var active_customer_path: NodePath
@onready var coins_label: Label = %CoinsLabel
@onready var order_label: Label = %OrderLabel
@onready var prepare_button: Button = %PrepareButton
@onready var coin_feedback_label: Label = %CoinFeedbackLabel
@onready var coin_feedback_timer: Timer = %CoinFeedbackTimer

var _cooking_stand: CookingStand
var _active_customer: Customer
var _active_order: Order


func _ready() -> void:
	prepare_button.pressed.connect(_on_prepare_button_pressed)
	coin_feedback_timer.timeout.connect(_on_coin_feedback_timer_timeout)
	GameManager.currency_changed.connect(_on_currency_changed)
	_resolve_configured_nodes()
	_connect_cooking_stand_signals()
	_refresh_active_order()
	_update_display()


func set_active_customer(customer: Customer) -> void:
	_active_customer = customer
	_refresh_active_order()
	_update_display()


func set_cooking_stand(cooking_stand: CookingStand) -> void:
	_disconnect_cooking_stand_signals()
	_cooking_stand = cooking_stand
	_connect_cooking_stand_signals()
	_update_display()


func _resolve_configured_nodes() -> void:
	if not cooking_stand_path.is_empty():
		var cooking_node: Node = get_node_or_null(cooking_stand_path)
		if cooking_node is CookingStand:
			_cooking_stand = cooking_node as CookingStand
		else:
			push_warning(COOKING_STAND_NOT_FOUND)

	if not active_customer_path.is_empty():
		var customer_node: Node = get_node_or_null(active_customer_path)
		if customer_node is Customer:
			_active_customer = customer_node as Customer


func _connect_cooking_stand_signals() -> void:
	if _cooking_stand == null:
		return

	if not _cooking_stand.cooking_started.is_connected(_on_cooking_started):
		_cooking_stand.cooking_started.connect(_on_cooking_started)

	if not _cooking_stand.cooking_completed.is_connected(_on_cooking_completed):
		_cooking_stand.cooking_completed.connect(_on_cooking_completed)


func _disconnect_cooking_stand_signals() -> void:
	if _cooking_stand == null:
		return

	if _cooking_stand.cooking_started.is_connected(_on_cooking_started):
		_cooking_stand.cooking_started.disconnect(_on_cooking_started)

	if _cooking_stand.cooking_completed.is_connected(_on_cooking_completed):
		_cooking_stand.cooking_completed.disconnect(_on_cooking_completed)


func _refresh_active_order() -> void:
	_active_order = null
	if _active_customer != null and _active_customer.has_order():
		_active_order = _active_customer.get_order()

	if _active_order != null and _cooking_stand != null and not _cooking_stand.has_active_order():
		_cooking_stand.accept_order(_active_order)


func _update_display() -> void:
	coins_label.text = COINS_PREFIX + str(GameManager.coins)
	order_label.text = _get_order_text()
	prepare_button.text = _get_prepare_button_text()
	prepare_button.disabled = not _can_prepare_order()



func show_coin_feedback(amount: int) -> void:
	if amount <= 0:
		return

	coin_feedback_label.text = COIN_FEEDBACK_PREFIX + str(amount) + COIN_FEEDBACK_SUFFIX
	coin_feedback_label.visible = true
	coin_feedback_timer.start(FEEDBACK_VISIBLE_SECONDS)

func _get_order_text() -> String:
	if _active_order == null:
		return NO_ORDER_TEXT

	return ORDER_PREFIX + _get_recipe_name(_active_order)


func _get_recipe_name(order: Order) -> String:
	if order.selected_recipe == null or order.selected_recipe.display_name.is_empty():
		return UNKNOWN_RECIPE_TEXT

	return order.selected_recipe.display_name


func _get_prepare_button_text() -> String:
	if _cooking_stand != null and _cooking_stand.is_cooking():
		return PREPARE_COOKING_TEXT

	return PREPARE_IDLE_TEXT


func _can_prepare_order() -> bool:
	return _cooking_stand != null and _cooking_stand.can_cook()


func _on_prepare_button_pressed() -> void:
	if _cooking_stand == null:
		return

	if _cooking_stand.start_cooking():
		_update_display()


func _on_cooking_started(_order: Order) -> void:
	_update_display()


func _on_cooking_completed(order: Order) -> void:
	_active_order = null
	order_ready.emit(order)
	_update_display()


func _on_currency_changed(_coins: int, _gems: int) -> void:
	_update_display()


func _on_coin_feedback_timer_timeout() -> void:
	coin_feedback_label.visible = false
