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
const UPGRADE_FEEDBACK_SECONDS: float = 1.5
const UPGRADE_FEEDBACK_TITLE: String = "🔥 Grill Upgraded!"
const UPGRADE_FEEDBACK_LEVEL_PREFIX: String = "Level "
const UPGRADE_FEEDBACK_SPEED_PREFIX: String = "Cooking Speed +"
const UPGRADE_FEEDBACK_SPEED_SUFFIX: String = "%"
const UPGRADE_FEEDBACK_RISE_PIXELS: float = 32.0
const UPGRADE_FEEDBACK_FADE_SECONDS: float = 0.25
const NO_ORDER_TIME_TEXT: String = "No active order"
const ORDER_TIME_SUFFIX: String = " sec prep"
const BUTTON_PRESSED_SCALE: Vector2 = Vector2(0.97, 0.97)
const BUTTON_NORMAL_SCALE: Vector2 = Vector2.ONE
const BUTTON_ANIMATION_SECONDS: float = 0.08
const ALL_INGREDIENTS_UNLOCKED_TEXT: String = "All ingredients unlocked"
const NEXT_INGREDIENT_PREFIX: String = "Next: "
const PANEL_WIDTH: float = 430.0
const PANEL_TOP: float = 160.0
const PANEL_ROW_SEPARATION: int = 8
const PANEL_HEIGHT: float = 520.0
const UNLOCKED_TEXT: String = "Unlocked"
const LOCKED_TEXT: String = "Locked"
const RARE_ORDER_TEXT: String = "Rare Order!"
const REPUTATION_FEEDBACK_PREFIX: String = "⭐ Reputation +"
const BUSINESS_LEVEL_UP_TITLE: String = "🏆 Business Level Up!"
const BUSINESS_LEVEL_PREFIX: String = "Level "
const BUSINESS_LEVEL_FEEDBACK_SECONDS: float = 2.0
const TIP_FEEDBACK_PREFIX: String = "💰 Tip +"
const COMBO_FEEDBACK_PREFIX: String = "🔥 Combo x"
const COMBO_INCREASED_TEXT: String = "Combo Increased!"
const ENABLE_DEV_MENU: bool = true
const DEV_BUTTON_TEXT: String = "DEV"
const DEV_MENU_TITLE: String = "Developer Menu"
const DEV_MENU_TESTING_NOTE: String = "Testing only. Disable before release."
const DEV_BUTTON_SIZE: Vector2 = Vector2(44.0, 36.0)
const DEV_BUTTON_FONT_SIZE: int = 11
const DEV_BUTTON_MARGIN: float = 16.0
const DEV_BUTTON_BOTTOM_OFFSET: float = 112.0
const DEV_UI_Z_INDEX: int = 1000
const DEV_BUTTON_CORNER_RADIUS: int = 10
const DEV_BUTTON_SHADOW_SIZE: int = 3
const DEV_BUTTON_SHADOW_OFFSET: Vector2 = Vector2(0.0, 2.0)
const DEV_BUTTON_BG_COLOR: Color = Color(0.29, 0.24, 0.12, 0.92)
const DEV_BUTTON_HOVER_COLOR: Color = Color(0.36, 0.29, 0.15, 0.96)
const DEV_BUTTON_PRESSED_COLOR: Color = Color(0.22, 0.18, 0.09, 0.96)
const DEV_BUTTON_SHADOW_COLOR: Color = Color(0.12, 0.08, 0.03, 0.28)
const DEV_MENU_WIDTH: float = 320.0
const DEV_MENU_HEIGHT: float = 460.0
const DEV_MENU_MARGIN: float = 14.0
const DEV_MENU_SECTION_FONT_SIZE: int = 16

@export var cooking_stand_path: NodePath
@export var active_customer_path: NodePath
@export var enable_dev_menu: bool = ENABLE_DEV_MENU
@onready var coins_label: Label = %CoinsLabel
@onready var reputation_label: Label = %ReputationLabel
@onready var business_level_label: Label = %BusinessLevelLabel
@onready var order_label: Label = %OrderLabel
@onready var order_time_label: Label = %OrderTimeLabel
@onready var prepare_button: Button = %PrepareButton
@onready var upgrade_button: Button = %UpgradeButton
@onready var cooking_status_label: Label = %CookingStatusLabel
@onready var recipes_button: Button = %RecipesButton
@onready var ingredients_button: Button = %IngredientsButton
@onready var business_button: Button = %BusinessButton
@onready var coin_feedback_label: Label = %CoinFeedbackLabel
@onready var coin_feedback_timer: Timer = %CoinFeedbackTimer
@onready var cooking_progress_bar: CookingProgressBar = %CookingProgressBar

var _cooking_stand: CookingStand
var _active_customer: Customer
var _active_order: Order
var _feedback_tween: Tween
var _coin_feedback_base_position: Vector2
var _recipes_panel: PanelContainer
var _ingredients_panel: PanelContainer
var _business_panel: PanelContainer
var _developer_ui: Control
var _dev_button: Button
var _dev_panel: PanelContainer


func _ready() -> void:
	_apply_mobile_hud_layout()
	prepare_button.pressed.connect(_on_prepare_button_pressed)
	prepare_button.button_down.connect(_on_prepare_button_down)
	prepare_button.button_up.connect(_on_prepare_button_up)
	upgrade_button.pressed.connect(_on_upgrade_button_pressed)
	recipes_button.pressed.connect(_on_recipes_button_pressed)
	ingredients_button.pressed.connect(_on_ingredients_button_pressed)
	business_button.pressed.connect(_on_business_button_pressed)
	coin_feedback_timer.timeout.connect(_on_coin_feedback_timer_timeout)
	_coin_feedback_base_position = coin_feedback_label.position
	GameManager.currency_changed.connect(_on_currency_changed)
	GameManager.upgrades_changed.connect(_on_upgrades_changed)
	GameManager.grill_upgraded.connect(_on_grill_upgraded)
	ReputationManager.reputation_changed.connect(_on_reputation_changed)
	ReputationManager.business_level_changed.connect(_on_business_level_changed)
	KioskUpgradeManager.kiosk_upgrades_changed.connect(_on_kiosk_upgrades_changed)
	IngredientManager.ingredients_changed.connect(_on_ingredients_changed)
	GameManager.recipes_changed.connect(_on_recipes_changed)
	_create_progression_panels()
	_create_dev_menu()
	_resolve_configured_nodes()
	_connect_cooking_stand_signals()
	cooking_progress_bar.set_cooking_stand(_cooking_stand)
	_refresh_active_order()
	_update_display()


func _exit_tree() -> void:
	_disconnect_cooking_stand_signals()
	if _developer_ui != null and is_instance_valid(_developer_ui):
		_developer_ui.queue_free()
		_developer_ui = null
	if GameManager.currency_changed.is_connected(_on_currency_changed):
		GameManager.currency_changed.disconnect(_on_currency_changed)
	if GameManager.upgrades_changed.is_connected(_on_upgrades_changed):
		GameManager.upgrades_changed.disconnect(_on_upgrades_changed)
	if GameManager.grill_upgraded.is_connected(_on_grill_upgraded):
		GameManager.grill_upgraded.disconnect(_on_grill_upgraded)
	if ReputationManager.reputation_changed.is_connected(_on_reputation_changed):
		ReputationManager.reputation_changed.disconnect(_on_reputation_changed)
	if ReputationManager.business_level_changed.is_connected(_on_business_level_changed):
		ReputationManager.business_level_changed.disconnect(_on_business_level_changed)
	if KioskUpgradeManager.kiosk_upgrades_changed.is_connected(_on_kiosk_upgrades_changed):
		KioskUpgradeManager.kiosk_upgrades_changed.disconnect(_on_kiosk_upgrades_changed)
	if IngredientManager.ingredients_changed.is_connected(_on_ingredients_changed):
		IngredientManager.ingredients_changed.disconnect(_on_ingredients_changed)
	if GameManager.recipes_changed.is_connected(_on_recipes_changed):
		GameManager.recipes_changed.disconnect(_on_recipes_changed)


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


func _apply_mobile_hud_layout() -> void:
	add_theme_constant_override("margin_left", 14)
	add_theme_constant_override("margin_top", 14)
	add_theme_constant_override("margin_right", 14)
	add_theme_constant_override("margin_bottom", 14)
	coins_label.add_theme_font_size_override("font_size", 24)
	reputation_label.add_theme_font_size_override("font_size", 16)
	business_level_label.add_theme_font_size_override("font_size", 16)
	order_label.add_theme_font_size_override("font_size", 18)
	order_time_label.add_theme_font_size_override("font_size", 12)
	cooking_status_label.add_theme_font_size_override("font_size", 16)
	prepare_button.add_theme_font_size_override("font_size", 17)
	upgrade_button.add_theme_font_size_override("font_size", 15)
	recipes_button.add_theme_font_size_override("font_size", 15)
	ingredients_button.add_theme_font_size_override("font_size", 15)
	business_button.add_theme_font_size_override("font_size", 15)


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
	reputation_label.text = "⭐ Reputation: %d" % ReputationManager.reputation
	business_level_label.text = "🏪 Business Level: %d" % ReputationManager.business_level
	order_label.text = _get_order_text()
	order_time_label.text = _get_order_time_text()
	prepare_button.text = _get_prepare_button_text()
	prepare_button.disabled = not _can_prepare_order()
	cooking_status_label.text = _get_cooking_status_text()
	upgrade_button.text = _get_upgrade_button_text()
	upgrade_button.disabled = GameManager.is_max_grill_level()
	_refresh_open_progression_panel()


func show_reward_feedback(reward_details: Dictionary) -> void:
	var total_coins: int = int(reward_details.get(GameManager.REWARD_TOTAL_KEY, 0))
	if total_coins <= 0:
		return

	_reset_feedback_animation()
	var lines: Array[String] = [COIN_FEEDBACK_PREFIX + str(total_coins) + COIN_FEEDBACK_SUFFIX]
	var tip_coins: int = int(reward_details.get(GameManager.REWARD_TIP_KEY, 0))
	if tip_coins > 0:
		lines.append(TIP_FEEDBACK_PREFIX + str(tip_coins))
	var combo_level: int = int(reward_details.get(GameManager.REWARD_COMBO_LEVEL_KEY, 0))
	if combo_level > 0:
		lines.append(COMBO_FEEDBACK_PREFIX + str(combo_level))
	if bool(reward_details.get(GameManager.REWARD_COMBO_INCREASED_KEY, false)):
		lines.append(COMBO_INCREASED_TEXT)
	coin_feedback_label.text = "\n".join(lines)
	coin_feedback_label.visible = true
	coin_feedback_timer.start(FEEDBACK_VISIBLE_SECONDS)

func show_coin_feedback(amount: int, bonus_label: String = "") -> void:
	if amount <= 0:
		return

	_reset_feedback_animation()
	coin_feedback_label.text = COIN_FEEDBACK_PREFIX + str(amount) + COIN_FEEDBACK_SUFFIX
	if not bonus_label.is_empty():
		coin_feedback_label.text += "\n" + bonus_label
	coin_feedback_label.visible = true
	coin_feedback_timer.start(FEEDBACK_VISIBLE_SECONDS)


func show_reputation_feedback(amount: int) -> void:
	if amount <= 0:
		return

	coin_feedback_label.text = REPUTATION_FEEDBACK_PREFIX + str(amount)
	coin_feedback_label.visible = true
	coin_feedback_label.modulate.a = 1.0
	coin_feedback_label.position = _coin_feedback_base_position
	_start_upgrade_feedback_animation()
	coin_feedback_timer.start(FEEDBACK_VISIBLE_SECONDS)


func show_business_level_feedback(level: int) -> void:
	coin_feedback_label.text = "%s\n%s%d" % [BUSINESS_LEVEL_UP_TITLE, BUSINESS_LEVEL_PREFIX, level]
	coin_feedback_label.visible = true
	coin_feedback_label.modulate.a = 1.0
	coin_feedback_label.position = _coin_feedback_base_position
	_start_feedback_animation(BUSINESS_LEVEL_FEEDBACK_SECONDS)
	coin_feedback_timer.start(BUSINESS_LEVEL_FEEDBACK_SECONDS)


func show_upgrade_feedback(level: int, speed_improvement_percent: int) -> void:
	coin_feedback_label.text = _get_upgrade_feedback_text(level, speed_improvement_percent)
	coin_feedback_label.visible = true
	coin_feedback_label.modulate.a = 1.0
	coin_feedback_label.position = _coin_feedback_base_position
	_start_upgrade_feedback_animation()
	coin_feedback_timer.start(UPGRADE_FEEDBACK_SECONDS)


func _get_upgrade_button_text() -> String:
	return GameManager.get_next_grill_button_text()


func _get_upgrade_feedback_text(level: int, speed_improvement_percent: int) -> String:
	return "%s\n%s%d\n%s%d%s" % [
		UPGRADE_FEEDBACK_TITLE,
		UPGRADE_FEEDBACK_LEVEL_PREFIX,
		level,
		UPGRADE_FEEDBACK_SPEED_PREFIX,
		speed_improvement_percent,
		UPGRADE_FEEDBACK_SPEED_SUFFIX,
	]


func _start_upgrade_feedback_animation() -> void:
	_start_feedback_animation(UPGRADE_FEEDBACK_SECONDS)


func _start_feedback_animation(duration_seconds: float) -> void:
	_reset_feedback_animation()
	_feedback_tween = create_tween()
	_feedback_tween.set_parallel(true)
	_feedback_tween.tween_property(coin_feedback_label, "position", _coin_feedback_base_position + Vector2.UP * UPGRADE_FEEDBACK_RISE_PIXELS, duration_seconds)
	_feedback_tween.tween_property(coin_feedback_label, "modulate:a", 0.0, UPGRADE_FEEDBACK_FADE_SECONDS).set_delay(duration_seconds - UPGRADE_FEEDBACK_FADE_SECONDS)


func _create_progression_panels() -> void:
	_recipes_panel = _create_base_panel("Recipe Menu", true)
	_ingredients_panel = _create_base_panel("Ingredient Shop")
	_business_panel = _create_base_panel("Business", true)
	add_child(_recipes_panel)
	add_child(_ingredients_panel)
	add_child(_business_panel)
	_recipes_panel.hide()
	_ingredients_panel.hide()
	_business_panel.hide()


func _create_dev_menu() -> void:
	if not enable_dev_menu:
		return

	_developer_ui = Control.new()
	_developer_ui.name = "DeveloperUI"
	_developer_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_developer_ui.clip_contents = false
	_developer_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	_developer_ui.offset_left = 0.0
	_developer_ui.offset_top = 0.0
	_developer_ui.offset_right = 0.0
	_developer_ui.offset_bottom = 0.0
	_developer_ui.z_index = DEV_UI_Z_INDEX
	add_child(_developer_ui)

	_dev_button = Button.new()
	_dev_button.text = DEV_BUTTON_TEXT
	_dev_button.custom_minimum_size = DEV_BUTTON_SIZE
	_dev_button.size = DEV_BUTTON_SIZE
	_dev_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_dev_button.add_theme_font_size_override("font_size", DEV_BUTTON_FONT_SIZE)
	_dev_button.add_theme_color_override("font_color", Color.WHITE)
	_dev_button.add_theme_color_override("font_hover_color", Color.WHITE)
	_dev_button.add_theme_color_override("font_pressed_color", Color.WHITE)
	_dev_button.add_theme_color_override("font_focus_color", Color.WHITE)
	_dev_button.add_theme_stylebox_override("normal", _create_dev_button_style(DEV_BUTTON_BG_COLOR, true))
	_dev_button.add_theme_stylebox_override("hover", _create_dev_button_style(DEV_BUTTON_HOVER_COLOR, true))
	_dev_button.add_theme_stylebox_override("pressed", _create_dev_button_style(DEV_BUTTON_PRESSED_COLOR, false))
	_dev_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	_dev_button.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_dev_button.offset_left = DEV_BUTTON_MARGIN
	_dev_button.offset_top = -DEV_BUTTON_SIZE.y - DEV_BUTTON_BOTTOM_OFFSET
	_dev_button.offset_right = DEV_BUTTON_MARGIN + DEV_BUTTON_SIZE.x
	_dev_button.offset_bottom = -DEV_BUTTON_BOTTOM_OFFSET
	_dev_button.z_index = DEV_UI_Z_INDEX
	_dev_button.pressed.connect(_on_dev_button_pressed)
	_developer_ui.add_child(_dev_button)

	_dev_panel = _create_base_panel(DEV_MENU_TITLE)
	_dev_panel.custom_minimum_size = Vector2(DEV_MENU_WIDTH, DEV_MENU_HEIGHT)
	_dev_panel.size = Vector2(DEV_MENU_WIDTH, DEV_MENU_HEIGHT)
	_dev_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_dev_panel.offset_left = DEV_BUTTON_MARGIN
	_dev_panel.offset_top = -DEV_MENU_HEIGHT - DEV_BUTTON_SIZE.y - DEV_MENU_MARGIN - DEV_BUTTON_BOTTOM_OFFSET
	_dev_panel.offset_right = DEV_BUTTON_MARGIN + DEV_MENU_WIDTH
	_dev_panel.offset_bottom = -DEV_BUTTON_SIZE.y - DEV_MENU_MARGIN - DEV_BUTTON_BOTTOM_OFFSET
	_dev_panel.z_index = DEV_UI_Z_INDEX - 1
	_developer_ui.add_child(_dev_panel)
	_populate_dev_panel()
	_dev_panel.hide()


func _create_dev_button_style(background_color: Color, include_shadow: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = background_color
	style.corner_radius_top_left = DEV_BUTTON_CORNER_RADIUS
	style.corner_radius_top_right = DEV_BUTTON_CORNER_RADIUS
	style.corner_radius_bottom_right = DEV_BUTTON_CORNER_RADIUS
	style.corner_radius_bottom_left = DEV_BUTTON_CORNER_RADIUS
	if include_shadow:
		style.shadow_color = DEV_BUTTON_SHADOW_COLOR
		style.shadow_size = DEV_BUTTON_SHADOW_SIZE
		style.shadow_offset = DEV_BUTTON_SHADOW_OFFSET
	return style


func _populate_dev_panel() -> void:
	var content: VBoxContainer = _get_panel_content(_dev_panel)
	_clear_panel_rows(content)
	content.add_child(_create_dev_label(DEV_MENU_TESTING_NOTE))
	content.add_child(_create_dev_section_label("Coins"))
	content.add_child(_create_dev_button_row([
		_create_dev_button("+100", _on_dev_add_coins_pressed.bind(100)),
		_create_dev_button("+1,000", _on_dev_add_coins_pressed.bind(1000)),
		_create_dev_button("+10,000", _on_dev_add_coins_pressed.bind(10000)),
	]))
	content.add_child(_create_dev_button("Reset Coins to 0", _on_dev_reset_coins_pressed))
	content.add_child(_create_dev_section_label("Unlocks"))
	content.add_child(_create_dev_button("Unlock All Ingredients", _on_dev_unlock_all_ingredients_pressed))
	content.add_child(_create_dev_label("Recipes unlock automatically from ingredients."))
	content.add_child(_create_dev_section_label("Grill Level"))
	content.add_child(_create_dev_button_row([
		_create_dev_button("Level 1", _on_dev_set_grill_level_pressed.bind(1)),
		_create_dev_button("Level 2", _on_dev_set_grill_level_pressed.bind(2)),
		_create_dev_button("Level 3", _on_dev_set_grill_level_pressed.bind(3)),
	]))
	content.add_child(_create_dev_button_row([
		_create_dev_button("Level 4", _on_dev_set_grill_level_pressed.bind(4)),
		_create_dev_button("Level 5", _on_dev_set_grill_level_pressed.bind(5)),
	]))
	content.add_child(_create_dev_section_label("Reputation"))
	content.add_child(_create_dev_button_row([
		_create_dev_button("+25", _on_dev_add_reputation_pressed.bind(25)),
		_create_dev_button("+100", _on_dev_add_reputation_pressed.bind(100)),
	]))


func _create_dev_label(text: String) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func _create_dev_section_label(text: String) -> Label:
	var label: Label = _create_dev_label(text)
	label.add_theme_font_size_override("font_size", DEV_MENU_SECTION_FONT_SIZE)
	return label


func _create_dev_button(text: String, callback: Callable) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(callback)
	return button


func _create_dev_button_row(buttons: Array[Button]) -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", PANEL_ROW_SEPARATION)
	for button: Button in buttons:
		row.add_child(button)
	return row


func _create_base_panel(title: String, has_scrollable_rows: bool = false) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(PANEL_WIDTH, PANEL_HEIGHT)
	panel.size = Vector2(PANEL_WIDTH, PANEL_HEIGHT)
	panel.position = Vector2(14.0, PANEL_TOP)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP

	var margin: MarginContainer = MarginContainer.new()
	margin.name = "PanelMargin"
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var content: VBoxContainer = VBoxContainer.new()
	content.name = "PanelContent"
	content.add_theme_constant_override("separation", PANEL_ROW_SEPARATION)
	margin.add_child(content)

	var header: HBoxContainer = HBoxContainer.new()
	content.add_child(header)
	var title_label: Label = Label.new()
	title_label.text = title
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.add_theme_font_size_override("font_size", 20)
	header.add_child(title_label)
	var close_button: Button = Button.new()
	close_button.text = "Close"
	close_button.pressed.connect(Callable(panel, "hide"))
	header.add_child(close_button)

	if has_scrollable_rows:
		var scroll_container: ScrollContainer = ScrollContainer.new()
		scroll_container.name = "RowsScroll"
		scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
		scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		content.add_child(scroll_container)

		var rows: VBoxContainer = VBoxContainer.new()
		rows.name = "Rows"
		rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		rows.add_theme_constant_override("separation", PANEL_ROW_SEPARATION)
		scroll_container.add_child(rows)

	return panel


func _populate_recipe_panel() -> void:
	var rows: VBoxContainer = _get_panel_rows(_recipes_panel)
	_clear_rows(rows)
	for recipe: Recipe in IngredientManager.get_all_recipes():
		rows.add_child(_create_recipe_row(recipe))


func _create_recipe_row(recipe: Recipe) -> Label:
	var status: String = UNLOCKED_TEXT if IngredientManager.is_recipe_available(recipe) else LOCKED_TEXT
	var lines: Array[String] = [
		"%s — %s" % [recipe.display_name, status],
		"Reward: %d" % GameManager.economy_config.get_recipe_reward(recipe),
		"Time: %.1fs" % GameManager.economy_config.get_recipe_preparation_time(recipe),
		"Requires:",
	]
	for ingredient: Ingredient in recipe.required_ingredients:
		var mark: String = "✅" if ingredient != null and IngredientManager.is_unlocked(ingredient.id) else "❌"
		var name: String = IngredientManager.get_display_name(ingredient.id) if ingredient != null else "Unknown"
		lines.append("%s %s" % [mark, name])

	var label: Label = Label.new()
	label.text = "\n".join(lines)
	return label


func _populate_ingredient_panel() -> void:
	var content: VBoxContainer = _get_panel_content(_ingredients_panel)
	_clear_panel_rows(content)
	for ingredient_id: String in IngredientManager.get_unlockable_ingredient_ids():
		content.add_child(_create_ingredient_row(ingredient_id))


func _create_ingredient_row(ingredient_id: String) -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", PANEL_ROW_SEPARATION)
	var label: Label = Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.text = "%s — %d Coins — %s" % [
		IngredientManager.get_display_label(ingredient_id),
		IngredientManager.get_unlock_cost(ingredient_id),
		UNLOCKED_TEXT if IngredientManager.is_unlocked(ingredient_id) else LOCKED_TEXT,
	]
	row.add_child(label)
	var button: Button = Button.new()
	button.text = "Unlocked" if IngredientManager.is_unlocked(ingredient_id) else "Buy"
	button.disabled = IngredientManager.is_unlocked(ingredient_id) or not IngredientManager.can_unlock(ingredient_id)
	button.pressed.connect(_on_ingredient_purchase_pressed.bind(ingredient_id))
	row.add_child(button)
	return row


func _get_panel_content(panel: PanelContainer) -> VBoxContainer:
	return panel.get_node("PanelMargin/PanelContent") as VBoxContainer


func _get_panel_rows(panel: PanelContainer) -> VBoxContainer:
	var scroll_rows: Node = panel.get_node_or_null("PanelMargin/PanelContent/RowsScroll/Rows")
	if scroll_rows is VBoxContainer:
		return scroll_rows as VBoxContainer

	return _get_panel_content(panel)


func _clear_panel_rows(content: VBoxContainer) -> void:
	for index: int in range(content.get_child_count() - 1, 0, -1):
		var row: Node = content.get_child(index)
		content.remove_child(row)
		row.queue_free()


func _clear_rows(rows: VBoxContainer) -> void:
	for child: Node in rows.get_children():
		rows.remove_child(child)
		child.queue_free()


func _refresh_open_progression_panel() -> void:
	if _recipes_panel != null and _recipes_panel.visible:
		_populate_recipe_panel()
	if _ingredients_panel != null and _ingredients_panel.visible:
		_populate_ingredient_panel()
	if _business_panel != null and _business_panel.visible:
		_populate_business_panel()


func _populate_business_panel() -> void:
	var rows: VBoxContainer = _get_panel_rows(_business_panel)
	_clear_rows(rows)
	rows.add_child(_create_business_section_label("Purchased Upgrades"))
	for purchased_upgrade: Dictionary in KioskUpgradeManager.get_purchased_upgrades():
		rows.add_child(_create_kiosk_upgrade_row(purchased_upgrade, true))
	rows.add_child(_create_business_section_label("Available Upgrades"))
	for available_upgrade: Dictionary in KioskUpgradeManager.get_available_upgrades():
		rows.add_child(_create_kiosk_upgrade_row(available_upgrade, false))


func _create_business_section_label(text: String) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 17)
	return label


func _create_kiosk_upgrade_row(upgrade: Dictionary, purchased: bool) -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", PANEL_ROW_SEPARATION)
	var label: Label = Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.text = "%s — %d Coins\n%s" % [upgrade.get("name", "Upgrade"), int(upgrade.get("cost", 0)), upgrade.get("description", "")]
	row.add_child(label)
	var button: Button = Button.new()
	button.text = "Purchased" if purchased else "Buy"
	button.disabled = purchased or not KioskUpgradeManager.can_purchase(StringName(str(upgrade.get("id", ""))))
	button.pressed.connect(_on_kiosk_upgrade_purchase_pressed.bind(StringName(str(upgrade.get("id", "")))))
	row.add_child(button)
	return row


func _get_cooking_status_text() -> String:
	var grill_text: String = "Grill Lv. %d" % GameManager.grill_level
	if _cooking_stand != null and _cooking_stand.is_cooking():
		return "%s • %s" % [COOKING_ORDER_TEXT, grill_text]

	if _cooking_stand != null and _cooking_stand.can_cook():
		return "Ready to cook • %s" % grill_text

	return "Idle • %s" % grill_text


func _get_order_text() -> String:
	if _cooking_stand != null and _cooking_stand.is_cooking():
		return COOKING_ORDER_TEXT

	if _active_order == null:
		return NO_ORDER_TEXT

	var order_lines: Array[String] = [_get_recipe_name(_active_order)]
	if _active_order.is_rare:
		order_lines.append(RARE_ORDER_TEXT)
	return "\n".join(order_lines)


func _get_order_time_text() -> String:
	if _active_order == null:
		return NO_ORDER_TIME_TEXT

	return str(snappedf(_get_modified_order_time(_active_order), 0.1)) + ORDER_TIME_SUFFIX


func _get_modified_order_time(order: Order) -> float:
	if order == null:
		return 0.0

	if _cooking_stand != null:
		return _cooking_stand.get_modified_preparation_time(order.preparation_time)

	return order.preparation_time * GameManager.cooking_speed_multiplier


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


func _on_recipes_button_pressed() -> void:
	AudioManager.play_button()
	_ingredients_panel.hide()
	_business_panel.hide()
	_hide_dev_panel()
	_populate_recipe_panel()
	_recipes_panel.visible = not _recipes_panel.visible


func _on_ingredients_button_pressed() -> void:
	AudioManager.play_button()
	_recipes_panel.hide()
	_business_panel.hide()
	_hide_dev_panel()
	_populate_ingredient_panel()
	_ingredients_panel.visible = not _ingredients_panel.visible


func _on_business_button_pressed() -> void:
	AudioManager.play_button()
	_recipes_panel.hide()
	_ingredients_panel.hide()
	_hide_dev_panel()
	_populate_business_panel()
	_business_panel.visible = not _business_panel.visible


func _hide_dev_panel() -> void:
	if _dev_panel != null:
		_dev_panel.hide()


func _on_dev_button_pressed() -> void:
	AudioManager.play_button()
	_recipes_panel.hide()
	_ingredients_panel.hide()
	_business_panel.hide()
	_dev_panel.visible = not _dev_panel.visible


func _on_dev_add_coins_pressed(amount: int) -> void:
	AudioManager.play_button()
	GameManager.add_dev_coins(amount)
	show_coin_feedback(amount)


func _on_dev_reset_coins_pressed() -> void:
	AudioManager.play_button()
	GameManager.set_coins(0)


func _on_dev_unlock_all_ingredients_pressed() -> void:
	AudioManager.play_button()
	IngredientManager.unlock_all_ingredients_for_testing()
	AudioManager.play_upgrade()
	_update_display()


func _on_dev_set_grill_level_pressed(level: int) -> void:
	AudioManager.play_button()
	GameManager.set_grill_level_for_testing(level)
	AudioManager.play_upgrade()
	_update_display()


func _on_dev_add_reputation_pressed(amount: int) -> void:
	AudioManager.play_button()
	ReputationManager.add_reputation(amount)


func _on_reputation_changed(_reputation: int, _business_level: int, amount_added: int) -> void:
	_update_display()
	show_reputation_feedback(amount_added)


func _on_business_level_changed(business_level: int) -> void:
	_update_display()
	show_business_level_feedback(business_level)


func _on_ingredient_purchase_pressed(ingredient_id: String) -> void:
	AudioManager.play_button()
	if IngredientManager.unlock_ingredient(ingredient_id):
		AudioManager.play_upgrade()
		_populate_ingredient_panel()
		if _recipes_panel.visible:
			_populate_recipe_panel()
		_update_display()


func _on_kiosk_upgrade_purchase_pressed(upgrade_id: StringName) -> void:
	AudioManager.play_button()
	if KioskUpgradeManager.purchase(upgrade_id):
		AudioManager.play_upgrade()
		_populate_business_panel()
		_update_display()


func _on_upgrade_button_pressed() -> void:
	AudioManager.play_button()
	if GameManager.purchase_next_grill_level():
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


func _on_grill_upgraded(level: int, speed_improvement_percent: int) -> void:
	show_upgrade_feedback(level, speed_improvement_percent)


func _on_ingredients_changed() -> void:
	_update_display()


func _on_recipes_changed() -> void:
	_refresh_open_progression_panel()


func _on_kiosk_upgrades_changed() -> void:
	_update_display()


func _reset_feedback_animation() -> void:
	if _feedback_tween != null:
		_feedback_tween.kill()
		_feedback_tween = null

	coin_feedback_label.modulate.a = 1.0
	coin_feedback_label.position = _coin_feedback_base_position


func _on_coin_feedback_timer_timeout() -> void:
	coin_feedback_label.visible = false
	_reset_feedback_animation()
