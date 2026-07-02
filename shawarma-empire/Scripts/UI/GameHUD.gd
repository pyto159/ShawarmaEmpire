extends MarginContainer
class_name GameHUD

signal order_ready(order: Order)

const NO_ORDER_TEXT: String = "Waiting"
const COOKING_ORDER_TEXT: String = "Cooking..."
const PREPARE_IDLE_TEXT: String = "Prepare"
const PREPARE_COOKING_TEXT: String = "Cooking..."
const UNKNOWN_RECIPE_TEXT: String = "Unknown Recipe"
const COOKING_STAND_NOT_FOUND: String = "Cooking stand was not found."
const COIN_FEEDBACK_PREFIX: String = "+"
const COIN_FEEDBACK_SUFFIX: String = " Coins"
const FEEDBACK_VISIBLE_SECONDS: float = 1.5
const NO_ORDER_TIME_TEXT: String = "No active order"
const ORDER_TIME_SUFFIX: String = " sec prep"
const PURCHASED_UPGRADE_TEXT: String = "Purchased"
const PANEL_CORNER_RADIUS: int = 22
const BUTTON_CORNER_RADIUS: int = 18
const ICON_CORNER_RADIUS: int = 21
const BUTTON_PRESSED_SCALE: Vector2 = Vector2(0.97, 0.97)
const BUTTON_NORMAL_SCALE: Vector2 = Vector2.ONE
const BUTTON_ANIMATION_SECONDS: float = 0.08
const BETTER_GRILL_UPGRADE: UpgradeData = preload("res://Resources/Upgrades/BetterGrill.tres")

@export var cooking_stand_path: NodePath
@export var active_customer_path: NodePath
@onready var coins_panel: PanelContainer = %CoinsPanel
@onready var coin_icon: PanelContainer = %CoinIcon
@onready var recipe_icon: PanelContainer = %RecipeIcon
@onready var order_panel: PanelContainer = %OrderPanel
@onready var coins_label: Label = %CoinsLabel
@onready var order_label: Label = %OrderLabel
@onready var order_time_label: Label = %OrderTimeLabel
@onready var prepare_button: Button = %PrepareButton
@onready var upgrade_button: Button = %UpgradeButton
@onready var coin_feedback_label: Label = %CoinFeedbackLabel
@onready var coin_feedback_timer: Timer = %CoinFeedbackTimer
@onready var cooking_progress_bar: CookingProgressBar = %CookingProgressBar

var _cooking_stand: CookingStand
var _active_customer: Customer
var _active_order: Order


func _ready() -> void:
	_apply_mobile_hud_theme()
	prepare_button.pressed.connect(_on_prepare_button_pressed)
	prepare_button.button_down.connect(_on_prepare_button_down)
	prepare_button.button_up.connect(_on_prepare_button_up)
	upgrade_button.pressed.connect(_on_upgrade_button_pressed)
	coin_feedback_timer.timeout.connect(_on_coin_feedback_timer_timeout)
	GameManager.currency_changed.connect(_on_currency_changed)
	GameManager.upgrades_changed.connect(_on_upgrades_changed)
	_resolve_configured_nodes()
	_connect_cooking_stand_signals()
	cooking_progress_bar.set_cooking_stand(_cooking_stand)
	_refresh_active_order()
	_update_display()


func _exit_tree() -> void:
	_disconnect_cooking_stand_signals()
	if GameManager.currency_changed.is_connected(_on_currency_changed):
		GameManager.currency_changed.disconnect(_on_currency_changed)
	if GameManager.upgrades_changed.is_connected(_on_upgrades_changed):
		GameManager.upgrades_changed.disconnect(_on_upgrades_changed)


func set_active_customer(customer: Customer) -> void:
	_active_customer = customer
	_refresh_active_order()
	_update_display()


func set_cooking_stand(cooking_stand: CookingStand) -> void:
	_disconnect_cooking_stand_signals()
	_cooking_stand = cooking_stand
	_connect_cooking_stand_signals()
	cooking_progress_bar.set_cooking_stand(_cooking_stand)
	_update_display()


func _apply_mobile_hud_theme() -> void:
	add_theme_constant_override("margin_left", 18)
	add_theme_constant_override("margin_top", 18)
	add_theme_constant_override("margin_right", 18)
	add_theme_constant_override("margin_bottom", 18)
	coins_panel.add_theme_stylebox_override("panel", _create_panel_style(Color(1.0, 0.78, 0.28, 0.96), Color(0.46, 0.24, 0.05, 0.20)))
	order_panel.add_theme_stylebox_override("panel", _create_panel_style(Color(1.0, 0.93, 0.82, 0.96), Color(0.32, 0.16, 0.06, 0.16)))
	coin_icon.add_theme_stylebox_override("panel", _create_icon_style(Color(1.0, 0.66, 0.08, 1.0)))
	recipe_icon.add_theme_stylebox_override("panel", _create_icon_style(Color(0.95, 0.52, 0.22, 1.0)))
	prepare_button.add_theme_stylebox_override("normal", _create_button_style(Color(0.25, 0.78, 0.34, 1.0), Color(0.06, 0.25, 0.09, 0.24)))
	prepare_button.add_theme_stylebox_override("hover", _create_button_style(Color(0.30, 0.84, 0.39, 1.0), Color(0.06, 0.25, 0.09, 0.24)))
	prepare_button.add_theme_stylebox_override("pressed", _create_button_style(Color(0.18, 0.62, 0.26, 1.0), Color(0.03, 0.12, 0.05, 0.18)))
	prepare_button.add_theme_stylebox_override("disabled", _create_button_style(Color(0.48, 0.50, 0.48, 1.0), Color(0.12, 0.12, 0.12, 0.10)))
	upgrade_button.add_theme_stylebox_override("normal", _create_button_style(Color(0.20, 0.50, 0.92, 1.0), Color(0.04, 0.12, 0.28, 0.22)))
	upgrade_button.add_theme_stylebox_override("hover", _create_button_style(Color(0.25, 0.58, 0.98, 1.0), Color(0.04, 0.12, 0.28, 0.22)))
	upgrade_button.add_theme_stylebox_override("pressed", _create_button_style(Color(0.13, 0.36, 0.72, 1.0), Color(0.02, 0.07, 0.18, 0.16)))
	upgrade_button.add_theme_stylebox_override("disabled", _create_button_style(Color(0.36, 0.46, 0.58, 1.0), Color(0.08, 0.10, 0.12, 0.10)))
	coins_label.add_theme_font_size_override("font_size", 28)
	order_label.add_theme_font_size_override("font_size", 20)
	order_time_label.add_theme_font_size_override("font_size", 14)
	prepare_button.add_theme_font_size_override("font_size", 22)
	upgrade_button.add_theme_font_size_override("font_size", 18)


func _create_panel_style(color: Color, shadow_color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = PANEL_CORNER_RADIUS
	style.corner_radius_top_right = PANEL_CORNER_RADIUS
	style.corner_radius_bottom_left = PANEL_CORNER_RADIUS
	style.corner_radius_bottom_right = PANEL_CORNER_RADIUS
	style.shadow_color = shadow_color
	style.shadow_size = 8
	style.shadow_offset = Vector2(0, 4)
	return style


func _create_icon_style(color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = _create_panel_style(color, Color(0, 0, 0, 0.12))
	style.corner_radius_top_left = ICON_CORNER_RADIUS
	style.corner_radius_top_right = ICON_CORNER_RADIUS
	style.corner_radius_bottom_left = ICON_CORNER_RADIUS
	style.corner_radius_bottom_right = ICON_CORNER_RADIUS
	return style


func _create_button_style(color: Color, shadow_color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = _create_panel_style(color, shadow_color)
	style.corner_radius_top_left = BUTTON_CORNER_RADIUS
	style.corner_radius_top_right = BUTTON_CORNER_RADIUS
	style.corner_radius_bottom_left = BUTTON_CORNER_RADIUS
	style.corner_radius_bottom_right = BUTTON_CORNER_RADIUS
	return style


func _animate_prepare_button(target_scale: Vector2) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(prepare_button, "scale", target_scale, BUTTON_ANIMATION_SECONDS)


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
	coins_label.text = CurrencyFormatter.format_coins(GameManager.coins)
	order_label.text = _get_order_text()
	order_time_label.text = _get_order_time_text()
	prepare_button.text = _get_prepare_button_text()
	prepare_button.disabled = not _can_prepare_order()
	var has_better_grill: bool = GameManager.has_upgrade(BETTER_GRILL_UPGRADE.id)
	upgrade_button.text = _get_upgrade_button_text(has_better_grill)
	upgrade_button.disabled = has_better_grill



func show_coin_feedback(amount: int) -> void:
	if amount <= 0:
		return

	coin_feedback_label.text = COIN_FEEDBACK_PREFIX + str(amount) + COIN_FEEDBACK_SUFFIX
	coin_feedback_label.visible = true
	coin_feedback_timer.start(FEEDBACK_VISIBLE_SECONDS)

func _get_upgrade_button_text(has_better_grill: bool) -> String:
	if has_better_grill:
		return PURCHASED_UPGRADE_TEXT

	return BETTER_GRILL_UPGRADE.get_button_text().replace(" - ", "\n")


func _get_order_text() -> String:
	if _cooking_stand != null and _cooking_stand.is_cooking():
		return COOKING_ORDER_TEXT

	if _active_order == null:
		return NO_ORDER_TEXT

	return _get_recipe_name(_active_order)


func _get_order_time_text() -> String:
	if _active_order == null:
		return NO_ORDER_TIME_TEXT

	return str(snappedf(_active_order.preparation_time, 0.1)) + ORDER_TIME_SUFFIX


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


func _on_prepare_button_down() -> void:
	_animate_prepare_button(BUTTON_PRESSED_SCALE)


func _on_prepare_button_up() -> void:
	_animate_prepare_button(BUTTON_NORMAL_SCALE)


func _on_prepare_button_pressed() -> void:
	AudioManager.play_button()
	if _cooking_stand == null:
		return

	if _cooking_stand.start_cooking():
		_update_display()


func _on_upgrade_button_pressed() -> void:
	AudioManager.play_button()
	if GameManager.purchase_upgrade(BETTER_GRILL_UPGRADE):
		AudioManager.play_upgrade()
		_update_display()


func _on_cooking_started(_order: Order) -> void:
	AudioManager.play_cooking_start()
	_update_display()


func _on_cooking_completed(order: Order) -> void:
	AudioManager.play_cooking_complete()
	_active_order = null
	order_ready.emit(order)
	_update_display()


func _on_currency_changed(_coins: int, _gems: int) -> void:
	_update_display()


func _on_upgrades_changed() -> void:
	_update_display()


func _on_coin_feedback_timer_timeout() -> void:
	coin_feedback_label.visible = false
