extends Control

const CUSTOMER_QUEUE_PATH: NodePath = NodePath("../CustomerQueue")
const CUSTOMER_EXIT_POSITION: Vector2 = Vector2(1100.0, 640.0)
const DEFAULT_SPAWN_INTERVAL: float = 3.0
const DEFAULT_MAX_ACTIVE_CUSTOMERS: int = 5
const DEFAULT_QUEUE_CAPACITY: int = 5
const FAVORITE_FEEDBACK_TEXT: String = "Favorite!"

@export var spawn_interval: float = DEFAULT_SPAWN_INTERVAL
@export var max_active_customers: int = DEFAULT_MAX_ACTIVE_CUSTOMERS
@export var queue_capacity: int = DEFAULT_QUEUE_CAPACITY

@onready var game_hud: GameHUD = $HUDLayer/GameHUD
@onready var cooking_stand: CookingStand = $World/CookingStand
@onready var customer_queue: QueueSystem = $World/CustomerQueue
@onready var customer_spawner: Spawner2D = $World/CustomerSpawner
@onready var spawned_customers: Node2D = $World/SpawnedCustomers

var active_customer: Customer
var _spawn_timer: Timer = Timer.new()
var _order_generator: OrderGenerator = OrderGenerator.new()


func _ready() -> void:
	SaveManager.load_game()
	_configure_customer_queue()
	_configure_customer_spawner()
	_configure_spawn_timer()
	_connect_cooking_stand()
	_connect_progression_signals()
	game_hud.set_cooking_stand(cooking_stand)
	_try_spawn_customer()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		SaveManager.save_game()


func _configure_customer_queue() -> void:
	if customer_queue == null:
		push_error("Main scene is missing a CustomerQueue reference.")
		return

	customer_queue.queue_capacity = queue_capacity
	customer_queue.collect_child_queue_points()
	if not customer_queue.reservation_created.is_connected(_on_queue_changed):
		customer_queue.reservation_created.connect(_on_queue_changed)
	if not customer_queue.reservation_cancelled.is_connected(_on_queue_slot_freed):
		customer_queue.reservation_cancelled.connect(_on_queue_slot_freed)
	if not customer_queue.reservation_completed.is_connected(_on_queue_slot_freed):
		customer_queue.reservation_completed.connect(_on_queue_slot_freed)


func _configure_customer_spawner() -> void:
	if customer_spawner == null or spawned_customers == null:
		push_error("Main scene is missing customer spawning references.")
		return

	customer_spawner.spawn_parent = spawned_customers
	customer_spawner.collect_child_spawn_points()
	if not customer_spawner.spawn_succeeded.is_connected(_on_customer_spawned):
		customer_spawner.spawn_succeeded.connect(_on_customer_spawned)


func _configure_spawn_timer() -> void:
	if _spawn_timer.timeout.is_connected(_on_spawn_timer_timeout):
		return

	_spawn_timer.one_shot = false
	_update_spawn_timer_wait_time()
	_spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(_spawn_timer)
	_spawn_timer.start()


func _connect_cooking_stand() -> void:
	if not cooking_stand.cooking_completed.is_connected(_on_cooking_completed):
		cooking_stand.cooking_completed.connect(_on_cooking_completed)


func _connect_progression_signals() -> void:
	if not GameManager.recipes_changed.is_connected(_on_recipes_changed):
		GameManager.recipes_changed.connect(_on_recipes_changed)
	if not KioskUpgradeManager.kiosk_upgrades_changed.is_connected(_on_kiosk_upgrades_changed):
		KioskUpgradeManager.kiosk_upgrades_changed.connect(_on_kiosk_upgrades_changed)


func _on_spawn_timer_timeout() -> void:
	_try_spawn_customer()


func _try_spawn_customer() -> void:
	if customer_spawner == null or customer_queue == null:
		return

	if _get_active_customer_count() >= max_active_customers:
		return

	if customer_queue.is_at_capacity():
		return

	customer_spawner.try_spawn()


func _on_customer_spawned(instance: Node, _definition: SpawnDefinition, _spawn_point: SpawnPoint2D) -> void:
	if not instance is Customer:
		return

	var customer: Customer = instance as Customer
	_assign_customer_order(customer)
	customer.queue_system_path = CUSTOMER_QUEUE_PATH
	customer.patience_multiplier = KioskUpgradeManager.get_customer_patience_multiplier()
	customer.left.connect(_on_customer_left, CONNECT_ONE_SHOT)
	AudioManager.play_customer_arrive()
	customer.join_queue(customer_queue)
	_update_active_customer()


func _assign_customer_order(customer: Customer) -> void:
	var available_recipes: Array[Recipe] = GameManager.get_unlocked_recipes()
	customer.available_recipes = available_recipes
	customer.assign_favorite_from_available_recipes()
	if customer.has_order():
		return

	var order: Order = _order_generator.generate_order(available_recipes)
	if order != null:
		customer.assign_order(order)


func _refresh_customer_recipe_options() -> void:
	var available_recipes: Array[Recipe] = GameManager.get_unlocked_recipes()
	for child: Node in spawned_customers.get_children():
		if child is Customer:
			var customer: Customer = child as Customer
			customer.available_recipes = available_recipes


func _on_customer_left(_customer: Customer) -> void:
	AudioManager.play_customer_leave()
	_update_active_customer()
	call_deferred("_try_spawn_customer")


func _on_queue_changed(_reservation: QueueReservation) -> void:
	AudioManager.play_queue_move()
	_update_active_customer()


func _on_queue_slot_freed(_reservation: QueueReservation) -> void:
	AudioManager.play_queue_move()
	_update_active_customer()
	call_deferred("_try_spawn_customer")


func _on_recipes_changed() -> void:
	_refresh_customer_recipe_options()
	_update_active_customer()


func _on_kiosk_upgrades_changed() -> void:
	_update_spawn_timer_wait_time()
	_apply_customer_patience_bonus()


func _update_spawn_timer_wait_time() -> void:
	_spawn_timer.wait_time = max(spawn_interval / KioskUpgradeManager.get_customer_spawn_rate_multiplier(), 0.1)


func _apply_customer_patience_bonus() -> void:
	for child: Node in spawned_customers.get_children():
		if child is Customer:
			(child as Customer).patience_multiplier = KioskUpgradeManager.get_customer_patience_multiplier()


func _update_active_customer() -> void:
	active_customer = _get_front_order_customer()
	game_hud.set_active_customer(active_customer)


func _get_front_order_customer() -> Customer:
	for reservation: QueueReservation in customer_queue.active_reservations:
		if reservation.requester is Customer:
			var customer: Customer = reservation.requester as Customer
			if customer.has_order():
				return customer

	return null


func _get_customer_for_order(order: Order) -> Customer:
	for child: Node in spawned_customers.get_children():
		if child is Customer:
			var customer: Customer = child as Customer
			if customer.get_order() == order:
				return customer

	return null


func _get_active_customer_count() -> int:
	var customer_count: int = 0
	for child: Node in spawned_customers.get_children():
		if child is Customer:
			customer_count += 1

	return customer_count


func _on_cooking_completed(order: Order) -> void:
	var served_customer: Customer = _get_customer_for_order(order)
	if order == null or served_customer == null:
		_update_active_customer()
		return

	var leave_target_position: Vector2 = CUSTOMER_EXIT_POSITION
	if not cooking_stand.deliver_completed_order(served_customer, leave_target_position):
		_update_active_customer()
		return

	var earned_coins: int = GameManager.calculate_order_reward(order, served_customer)
	if earned_coins > 0:
		GameManager.add_coins(earned_coins)
		AudioManager.play_coin()
		var bonus_label: String = FAVORITE_FEEDBACK_TEXT if served_customer.is_favorite_order(order) else ""
		game_hud.show_coin_feedback(earned_coins, bonus_label)
		_show_floating_coin_feedback(served_customer.global_position, earned_coins)
		SaveManager.queue_save_game()

	_update_active_customer()


func _show_floating_coin_feedback(source_position: Vector2, amount: int) -> void:
	EffectsManager.spawn_coin_popup(source_position, amount)
