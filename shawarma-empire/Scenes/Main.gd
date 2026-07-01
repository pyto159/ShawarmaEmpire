extends Control

const CUSTOMER_QUEUE_PATH: NodePath = NodePath("../CustomerQueue")
const CUSTOMER_EXIT_OFFSET: Vector2 = Vector2(-160.0, 0.0)

@onready var game_hud: GameHUD = $GameHUD
@onready var cooking_stand: CookingStand = $World/CookingStand
@onready var customer_queue: QueueSystem = $World/CustomerQueue
@onready var customer_spawner: Spawner2D = $World/CustomerSpawner
@onready var spawned_customers: Node2D = $World/SpawnedCustomers

var active_customer: Customer


func _ready() -> void:
	SaveManager.load_game()
	_configure_customer_spawner()
	_connect_cooking_stand()
	game_hud.set_cooking_stand(cooking_stand)
	_spawn_next_customer()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		SaveManager.save_game()


func _configure_customer_spawner() -> void:
	customer_spawner.spawn_parent = spawned_customers
	if not customer_spawner.spawn_succeeded.is_connected(_on_customer_spawned):
		customer_spawner.spawn_succeeded.connect(_on_customer_spawned)


func _connect_cooking_stand() -> void:
	if not cooking_stand.cooking_completed.is_connected(_on_cooking_completed):
		cooking_stand.cooking_completed.connect(_on_cooking_completed)


func _spawn_next_customer() -> void:
	customer_spawner.try_spawn()


func _on_customer_spawned(instance: Node, _definition: SpawnDefinition, _spawn_point: SpawnPoint2D) -> void:
	if not instance is Customer:
		return

	var customer: Customer = instance as Customer
	active_customer = customer
	game_hud.set_active_customer(active_customer)
	active_customer.queue_system_path = CUSTOMER_QUEUE_PATH
	active_customer.left.connect(_on_customer_left, CONNECT_ONE_SHOT)
	active_customer.join_queue(customer_queue)


func _on_customer_left(_customer: Customer) -> void:
	active_customer = null
	game_hud.set_active_customer(null)
	call_deferred("_spawn_next_customer")


func _on_cooking_completed(order: Order) -> void:
	if order == null or active_customer == null:
		return

	var leave_target_position: Vector2 = active_customer.global_position + CUSTOMER_EXIT_OFFSET
	cooking_stand.deliver_completed_order(active_customer, leave_target_position)
