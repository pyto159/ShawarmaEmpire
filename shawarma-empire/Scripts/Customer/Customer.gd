extends CharacterBody2D
class_name Customer

signal state_changed(new_state: CustomerState)
signal queue_reservation_changed(reservation: QueueReservation)
signal order_changed(order: Order)
signal order_completed(order: Order)

const DEFAULT_MOVE_SPEED: float = 90.0
const ARRIVAL_DISTANCE: float = 4.0
const DEFAULT_QUEUE_PRIORITY: int = 0

const QUEUE_SYSTEM_PATH_NOT_CONFIGURED: String = "Queue system path is not configured."
const QUEUE_SYSTEM_NOT_FOUND: String = "Queue system was not found."


enum CustomerState {
	IDLE,
	WALKING,
	WAITING,
	LEAVING,
}

@export var move_speed: float = DEFAULT_MOVE_SPEED
@export var queue_system_path: NodePath
@export var queue_priority: int = DEFAULT_QUEUE_PRIORITY
@export var join_queue_on_ready: bool = false
@export var starting_order: Order

var current_state: CustomerState = CustomerState.IDLE
var _target_position: Vector2 = Vector2.ZERO
var _has_target_position: bool = false
var _queue_system: QueueSystem
var _queue_reservation: QueueReservation
var current_order: Order
var _is_waiting_for_queue_reservation: bool = false


func _ready() -> void:
	_target_position = global_position
	_set_queue_system(_get_configured_queue_system())
	if starting_order != null:
		assign_order(starting_order)
	if join_queue_on_ready:
		join_queue(_queue_system)


func _exit_tree() -> void:
	leave_queue()
	_disconnect_queue_system_signals()


func _physics_process(_delta: float) -> void:
	match current_state:
		CustomerState.IDLE:
			_stop_moving()
		CustomerState.WALKING, CustomerState.LEAVING:
			_move_toward_target()
		CustomerState.WAITING:
			_stop_moving()


func walk_to(target_position: Vector2) -> void:
	_target_position = target_position
	_has_target_position = true
	_set_state(CustomerState.WALKING)


func wait_for_service() -> void:
	_has_target_position = false
	_set_state(CustomerState.WAITING)


func leave_to(target_position: Vector2) -> void:
	leave_queue()
	_target_position = target_position
	_has_target_position = true
	_set_state(CustomerState.LEAVING)


func set_idle() -> void:
	_has_target_position = false
	_set_state(CustomerState.IDLE)


func assign_order(order: Order) -> void:
	if current_order == order:
		return

	current_order = order
	order_changed.emit(current_order)


func clear_order() -> void:
	if current_order == null:
		return

	current_order = null
	order_changed.emit(null)


func complete_current_order() -> void:
	if current_order == null or current_order.is_completed:
		return

	current_order.complete()
	order_completed.emit(current_order)


func has_active_order() -> bool:
	return current_order != null and not current_order.is_completed


func join_configured_queue() -> QueueReservation:
	return join_queue(_queue_system)


func join_queue(queue_system: QueueSystem) -> QueueReservation:
	if queue_system == null:
		push_warning(QUEUE_SYSTEM_NOT_FOUND)
		return null

	_set_queue_system(queue_system)
	if has_queue_reservation():
		return _queue_reservation

	if queue_system.has_waiting_request(self):
		_is_waiting_for_queue_reservation = true
		return null

	_is_waiting_for_queue_reservation = true
	var reservation: QueueReservation = queue_system.try_reserve(self, queue_priority)
	if reservation != null:
		_set_queue_reservation(reservation)

	return reservation


func leave_queue() -> void:
	if _queue_system == null:
		_clear_queue_reservation()
		return

	if _queue_reservation != null:
		_queue_system.cancel_reservation(_queue_reservation)
	else:
		_queue_system.cancel_request(self)

	_is_waiting_for_queue_reservation = false
	_clear_queue_reservation()


func complete_queue_service() -> void:
	if _queue_system == null or _queue_reservation == null:
		return

	_is_waiting_for_queue_reservation = false
	_queue_system.complete_reservation(_queue_reservation)
	_clear_queue_reservation()


func has_queue_reservation() -> bool:
	return _queue_reservation != null and _queue_reservation.is_active()


func _set_queue_system(queue_system: QueueSystem) -> void:
	if _queue_system == queue_system:
		return

	_disconnect_queue_system_signals()
	_queue_system = queue_system
	if _queue_system != null:
		_queue_system.reservation_created.connect(_on_queue_reservation_created)


func _disconnect_queue_system_signals() -> void:
	if _queue_system == null:
		return

	if _queue_system.reservation_created.is_connected(_on_queue_reservation_created):
		_queue_system.reservation_created.disconnect(_on_queue_reservation_created)


func _set_queue_reservation(reservation: QueueReservation) -> void:
	_is_waiting_for_queue_reservation = false
	if _queue_reservation == reservation:
		_move_to_reserved_queue_point()
		return

	_clear_queue_reservation()
	_queue_reservation = reservation
	_queue_reservation.queue_point_changed.connect(_on_queue_point_changed)
	_queue_reservation.cancelled.connect(_on_queue_reservation_released, CONNECT_ONE_SHOT)
	_queue_reservation.completed.connect(_on_queue_reservation_released, CONNECT_ONE_SHOT)
	queue_reservation_changed.emit(_queue_reservation)
	_move_to_reserved_queue_point()


func _clear_queue_reservation() -> void:
	if _queue_reservation == null:
		return

	_disconnect_queue_reservation_signals()
	_queue_reservation = null
	queue_reservation_changed.emit(null)


func _disconnect_queue_reservation_signals() -> void:
	if _queue_reservation.queue_point_changed.is_connected(_on_queue_point_changed):
		_queue_reservation.queue_point_changed.disconnect(_on_queue_point_changed)

	if _queue_reservation.cancelled.is_connected(_on_queue_reservation_released):
		_queue_reservation.cancelled.disconnect(_on_queue_reservation_released)

	if _queue_reservation.completed.is_connected(_on_queue_reservation_released):
		_queue_reservation.completed.disconnect(_on_queue_reservation_released)


func _move_to_reserved_queue_point() -> void:
	if _queue_reservation == null or _queue_reservation.queue_point == null:
		return

	walk_to(_queue_reservation.queue_point.global_position)


func _get_configured_queue_system() -> QueueSystem:
	if queue_system_path.is_empty():
		if join_queue_on_ready:
			push_warning(QUEUE_SYSTEM_PATH_NOT_CONFIGURED)
		return null

	var node: Node = get_node_or_null(queue_system_path)
	if node is QueueSystem:
		return node as QueueSystem

	push_warning(QUEUE_SYSTEM_NOT_FOUND)
	return null


func _on_queue_reservation_created(reservation: QueueReservation) -> void:
	if not _is_waiting_for_queue_reservation or reservation.requester != self:
		return

	_set_queue_reservation(reservation)


func _on_queue_point_changed(_reservation: QueueReservation, _queue_point: QueuePoint2D) -> void:
	_move_to_reserved_queue_point()


func _on_queue_reservation_released(_reservation: QueueReservation) -> void:
	_clear_queue_reservation()
	set_idle()


func _move_toward_target() -> void:
	if not _has_target_position:
		_stop_moving()
		return

	var distance_to_target: float = global_position.distance_to(_target_position)
	if distance_to_target <= ARRIVAL_DISTANCE:
		global_position = _target_position
		_has_target_position = false
		_stop_moving()
		if current_state == CustomerState.WALKING:
			_set_state(CustomerState.WAITING)
		return

	var movement_direction: Vector2 = global_position.direction_to(_target_position)
	velocity = movement_direction * move_speed
	move_and_slide()


func _stop_moving() -> void:
	velocity = Vector2.ZERO


func _set_state(new_state: CustomerState) -> void:
	if current_state == new_state:
		return

	current_state = new_state
	state_changed.emit(current_state)
