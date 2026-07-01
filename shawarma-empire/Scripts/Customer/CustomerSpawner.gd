class_name CustomerSpawner
extends Node2D
## Spawns customers for the first playable loop.
##
## The spawner enforces a single active customer and retries on a timer until
## the current customer leaves.

const DEFAULT_SPAWN_INTERVAL: float = 3.0

@export var customer_scene: PackedScene
@export var spawn_interval: float = DEFAULT_SPAWN_INTERVAL
@export var waiting_point: Node2D
@export var exit_point: Node2D

var active_customer: Customer

@onready var spawn_timer: Timer = $SpawnTimer


func _ready() -> void:
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()
	_spawn_customer()


func _on_spawn_timer_timeout() -> void:
	_spawn_customer()


func _spawn_customer() -> void:
	if active_customer != null or customer_scene == null:
		return

	var customer: Customer = customer_scene.instantiate() as Customer
	if customer == null:
		return

	customer.global_position = global_position
	customer.waiting_point = waiting_point.global_position
	customer.exit_point = exit_point.global_position
	customer.departed.connect(_on_customer_departed)
	get_parent().add_child(customer)
	active_customer = customer


func _on_customer_departed(customer: Customer) -> void:
	if active_customer == customer:
		active_customer = null
