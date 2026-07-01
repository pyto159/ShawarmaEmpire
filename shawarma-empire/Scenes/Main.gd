extends Control

const CUSTOMER_QUEUE_PATH: NodePath = NodePath("../CustomerQueue")
const CUSTOMER_EXIT_OFFSET: Vector2 = Vector2(-160.0, 0.0)
const DEFAULT_SPAWN_INTERVAL: float = 3.0
const DEFAULT_MAX_ACTIVE_CUSTOMERS: int = 4
const DEFAULT_QUEUE_CAPACITY: int = 4

@export var spawn_interval: float = DEFAULT_SPAWN_INTERVAL
@export var max_active_customers: int = DEFAULT_MAX_ACTIVE_CUSTOMERS
@export var queue_capacity: int = DEFAULT_QUEUE_CAPACITY

@onready var game_hud: GameHUD = $GameHUD
@onready var cooking_stand: CookingStand = $World/CookingStand
@onready var customer_queue: QueueSystem = $World/CustomerQueue
@onready var customer_spawner: Spawner2D = $World/CustomerSpawner
@onready var spawned_customers: Node2D = $World/SpawnedCustomers

var active_customer: Customer
var _spawn_timer: Timer = Timer.new()


func _ready() -> void:
	SaveManager.load_game()
	_configure_customer_queue()
	_configure_customer_spawner()
	_configure_spawn_timer()
	_connect_cooking_stand()
	game_hud.set_cooking_stand(cooking_stand)
	_try_spawn_customer()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		SaveManager.save_game()


func _configure_customer_queue() -> void:
	customer_queue.queue_capacity = queue_capacity
	if not customer_queue.reservation_created.is_connected(_on_queue_changed):
		customer_queue.reservation_created.connect(_on_queue_changed)
	if not customer_queue.reservation_cancelled.is_connected(_on_queue_slot_freed):
		customer_queue.reservation_cancelled.connect(_on_queue_slot_freed)
	if not customer_queue.reservation_completed.is_connected(_on_queue_slot_freed):
		customer_queue.reservation_completed.connect(_on_queue_slot_freed)


func _configure_customer_spawner() -> void:
	customer_spawner.spawn_parent = spawned_customers
	if not customer_spawner.spawn_succeeded.is_connected(_on_customer_spawned):
		customer_spawner.spawn_succeeded.connect(_on_customer_spawned)


func _configure_spawn_timer() -> void:
	_spawn_timer.one_shot = false
	_spawn_timer.wait_time = max(spawn_interval, 0.1)
	_spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(_spawn_timer)
	_spawn_timer.start()


func _connect_cooking_stand() -> void:
	if not cooking_stand.cooking_completed.is_connected(_on_cooking_completed):
		cooking_stand.cooking_completed.connect(_on_cooking_completed)


func _on_spawn_timer_timeout() -> void:
	_try_spawn_customer()


func _try_spawn_customer() -> void:
	if _get_active_customer_count() >= max_active_customers:
		return

	if customer_queue.is_at_capacity():
		return

	customer_spawner.try_spawn()


func _on_customer_spawned(instance: Node, _definition: SpawnDefinition, _spawn_point: SpawnPoint2D) -> void:
	if not instance is Customer:
		return

	var customer: Customer = instance as Customer
	customer.queue_system_path = CUSTOMER_QUEUE_PATH
	customer.left.connect(_on_customer_left, CONNECT_ONE_SHOT)
	customer.join_queue(customer_queue)
	_update_active_customer()


func _on_customer_left(_customer: Customer) -> void:
	_update_active_customer()
	call_deferred("_try_spawn_customer")


func _on_queue_changed(_reservation: QueueReservation) -> void:
	_update_active_customer()


func _on_queue_slot_freed(_reservation: QueueReservation) -> void:
	_update_active_customer()
	call_deferred("_try_spawn_customer")


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

	var leave_target_position: Vector2 = served_customer.global_position + CUSTOMER_EXIT_OFFSET
	if not cooking_stand.deliver_completed_order(served_customer, leave_target_position):
		_update_active_customer()
		return

	var earned_coins: int = max(order.total_price, 0)
	if earned_coins > 0:
		GameManager.add_coins(earned_coins)
		game_hud.show_coin_feedback(earned_coins)

	_update_active_customer()
