extends Node2D
class_name ShawarmaStand

signal service_started(reservation: QueueReservation)
signal service_completed(reservation: QueueReservation)

const DEFAULT_SERVICE_DURATION_SECONDS: float = 2.0
const QUEUE_SYSTEM_PATH_NOT_CONFIGURED: String = "Queue system path is not configured."
const QUEUE_SYSTEM_NOT_FOUND: String = "Queue system was not found."
const NO_COIN_REWARD: int = 0

@export var queue_system_path: NodePath
@export var service_duration_seconds: float = DEFAULT_SERVICE_DURATION_SECONDS

var _queue_system: QueueSystem
var _active_reservation: QueueReservation
var _remaining_service_seconds: float = 0.0


func _ready() -> void:
	_set_queue_system(_get_configured_queue_system())
	_try_start_next_service()


func _process(delta: float) -> void:
	if _active_reservation == null:
		_try_start_next_service()
		return

	_remaining_service_seconds -= delta
	if _remaining_service_seconds <= 0.0:
		_complete_active_service()


func _exit_tree() -> void:
	_disconnect_queue_system_signals()


func _set_queue_system(queue_system: QueueSystem) -> void:
	if _queue_system == queue_system:
		return

	_disconnect_queue_system_signals()
	_queue_system = queue_system
	_connect_queue_system_signals()


func _connect_queue_system_signals() -> void:
	if _queue_system == null:
		return

	_queue_system.reservation_created.connect(_on_queue_changed)
	_queue_system.reservation_cancelled.connect(_on_queue_changed)
	_queue_system.reservation_completed.connect(_on_queue_changed)


func _disconnect_queue_system_signals() -> void:
	if _queue_system == null:
		return

	if _queue_system.reservation_created.is_connected(_on_queue_changed):
		_queue_system.reservation_created.disconnect(_on_queue_changed)

	if _queue_system.reservation_cancelled.is_connected(_on_queue_changed):
		_queue_system.reservation_cancelled.disconnect(_on_queue_changed)

	if _queue_system.reservation_completed.is_connected(_on_queue_changed):
		_queue_system.reservation_completed.disconnect(_on_queue_changed)


func _try_start_next_service() -> void:
	if _queue_system == null or _active_reservation != null:
		return

	var next_reservation: QueueReservation = _get_front_ready_reservation()
	if next_reservation == null:
		return

	_active_reservation = next_reservation
	_remaining_service_seconds = max(service_duration_seconds, 0.0)
	service_started.emit(_active_reservation)
	if is_zero_approx(_remaining_service_seconds):
		_complete_active_service()


func _complete_active_service() -> void:
	var completed_reservation: QueueReservation = _active_reservation
	_active_reservation = null
	_remaining_service_seconds = 0.0
	if completed_reservation == null or not completed_reservation.is_active():
		_try_start_next_service()
		return

	if completed_reservation.requester is Customer:
		var customer: Customer = completed_reservation.requester as Customer
		var earned_coins: int = _complete_customer_order(customer)
		if earned_coins > NO_COIN_REWARD:
			GameManager.add_coins(earned_coins)
		customer.complete_queue_service()
	else:
		_queue_system.complete_reservation(completed_reservation)

	service_completed.emit(completed_reservation)
	_try_start_next_service()


func _complete_customer_order(customer: Customer) -> int:
	var order: Order = customer.current_order
	if order == null or not customer.complete_current_order():
		return NO_COIN_REWARD

	return max(order.total_price, NO_COIN_REWARD)


func _get_front_ready_reservation() -> QueueReservation:
	if _queue_system.queue_points.is_empty():
		return null

	var front_queue_point: QueuePoint2D = _queue_system.queue_points.front()
	var reservation: QueueReservation = _queue_system.get_reservation_for_queue_point(front_queue_point)
	if reservation == null or not _is_requester_ready(reservation):
		return null

	return reservation


func _is_requester_ready(reservation: QueueReservation) -> bool:
	if reservation.requester is Customer:
		var customer: Customer = reservation.requester as Customer
		return customer.current_state == Customer.CustomerState.WAITING

	return true


func _get_configured_queue_system() -> QueueSystem:
	if queue_system_path.is_empty():
		push_warning(QUEUE_SYSTEM_PATH_NOT_CONFIGURED)
		return null

	var node: Node = get_node_or_null(queue_system_path)
	if node is QueueSystem:
		return node as QueueSystem

	push_warning(QUEUE_SYSTEM_NOT_FOUND)
	return null


func _on_queue_changed(_reservation: QueueReservation) -> void:
	if _active_reservation != null and not _active_reservation.is_active():
		_active_reservation = null
		_remaining_service_seconds = 0.0

	_try_start_next_service()
