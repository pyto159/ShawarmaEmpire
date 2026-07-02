extends CharacterBody2D
class_name Customer

signal state_changed(new_state: CustomerState)
signal queue_reservation_changed(reservation: QueueReservation)
signal order_created(order: Order)
signal order_changed(order: Order)
signal order_completed(order: Order)
signal food_received(order: Order)
signal left(customer: Customer)

const DEFAULT_MOVE_SPEED: float = 54.0
const ARRIVAL_DISTANCE: float = 4.0
const DEFAULT_QUEUE_PRIORITY: int = 0
const QUEUE_MOVE_DURATION_SECONDS: float = 0.58
const QUEUE_MOVE_FOLLOW_DELAY_SECONDS: float = 0.26

const QUEUE_SYSTEM_PATH_NOT_CONFIGURED: String = "Queue system path is not configured."
const QUEUE_SYSTEM_NOT_FOUND: String = "Queue system was not found."
const ORDER_NOT_FOUND: String = "Cannot assign a null order."
const ACTIVE_ORDER_ALREADY_EXISTS: String = "Customer already owns an active order."
const BODY_COLORS: Array[Color] = [
	Color(0.93, 0.36, 0.22, 1.0),
	Color(0.22, 0.56, 0.84, 1.0),
	Color(0.24, 0.68, 0.46, 1.0),
	Color(0.72, 0.36, 0.86, 1.0),
	Color(0.95, 0.62, 0.20, 1.0),
]
const SKIN_TONES: Array[Color] = [
	Color(0.96, 0.72, 0.52, 1.0),
	Color(0.84, 0.58, 0.39, 1.0),
	Color(0.68, 0.42, 0.27, 1.0),
	Color(0.48, 0.29, 0.19, 1.0),
]
const HAIR_COLORS: Array[Color] = [
	Color(0.16, 0.09, 0.04, 1.0),
	Color(0.36, 0.22, 0.10, 1.0),
	Color(0.08, 0.07, 0.06, 1.0),
	Color(0.82, 0.58, 0.26, 1.0),
]
const CUSTOMER_SCALE_MIN: float = 0.94
const CUSTOMER_SCALE_MAX: float = 1.06


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
@export var create_order_on_ready: bool = true
@export var available_recipes: Array[Recipe] = []
@export var starting_order: Order
@export var food_visual_path: NodePath
@export var free_on_leave_completed: bool = true

var current_state: CustomerState = CustomerState.IDLE
var _target_position: Vector2 = Vector2.ZERO
var _has_target_position: bool = false
var _queue_system: QueueSystem
var _queue_reservation: QueueReservation
var current_order: Order
var received_order: Order
var has_received_food: bool = false
var _order_generator: OrderGenerator = OrderGenerator.new()
var _is_waiting_for_queue_reservation: bool = false
var _food_visual: CanvasItem
var _movement_tween: Tween
var _movement_sequence: int = 0
@onready var _body_visual: Node2D = $Body
@onready var _shirt_visual: Polygon2D = $Body/Shirt
@onready var _head_visual: Polygon2D = $Body/Head
@onready var _left_arm_visual: Polygon2D = $Body/LeftArm
@onready var _right_arm_visual: Polygon2D = $Body/RightArm
@onready var _hair_visual: Polygon2D = $Body/Hair


func _ready() -> void:
	_apply_random_visual_style()
	_target_position = global_position
	_set_food_visual(_get_configured_food_visual())
	_set_queue_system(_get_configured_queue_system())
	if starting_order != null:
		assign_order(starting_order)
	elif create_order_on_ready:
		_create_order()
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
	_cancel_movement_tween()
	_target_position = target_position
	_has_target_position = true
	_set_state(CustomerState.WALKING)


func wait_for_service() -> void:
	_cancel_movement_tween()
	_has_target_position = false
	_set_state(CustomerState.WAITING)


func leave_to(target_position: Vector2) -> void:
	_cancel_movement_tween()
	leave_queue()
	_target_position = target_position
	_has_target_position = true
	_set_state(CustomerState.LEAVING)


func set_idle() -> void:
	_cancel_movement_tween()
	_has_target_position = false
	_set_state(CustomerState.IDLE)


func get_order() -> Order:
	return current_order


func has_order() -> bool:
	return current_order != null and not current_order.is_completed


func complete_order() -> bool:
	return receive_food(current_order)


func receive_food(order: Order) -> bool:
	if order == null or order != current_order or not has_order():
		return false

	if not current_order.complete():
		return false

	_mark_food_received()
	order_completed.emit(current_order)
	return true


func receive_completed_order(order: Order, leave_target_position: Vector2) -> bool:
	if not can_receive_completed_order(order):
		return false

	_mark_food_received()
	leave_to(leave_target_position)
	return true


func can_receive_completed_order(order: Order) -> bool:
	return order != null and order == current_order and order.is_completed and not has_received_food


func _mark_food_received() -> void:
	received_order = current_order
	has_received_food = true
	_show_food_visual()
	food_received.emit(current_order)



func assign_order(order: Order) -> void:
	if order == null:
		push_warning(ORDER_NOT_FOUND)
		return

	if current_order == order:
		return

	if has_order():
		push_warning(ACTIVE_ORDER_ALREADY_EXISTS)
		return

	current_order = order
	received_order = null
	has_received_food = false
	_hide_food_visual()
	order_created.emit(current_order)
	order_changed.emit(current_order)



func complete_current_order() -> bool:
	return complete_order()


func has_active_order() -> bool:
	return has_order()


func _create_order() -> void:
	if has_order():
		return

	var generated_order: Order = _order_generator.generate_order(available_recipes)
	if generated_order == null:
		return

	assign_order(generated_order)


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

	var queue_move_delay: float = _get_queue_move_delay(_queue_reservation.queue_point)
	queue_walk_to(_queue_reservation.queue_point.global_position, queue_move_delay)


func _get_configured_food_visual() -> CanvasItem:
	if food_visual_path.is_empty():
		return null

	var node: Node = get_node_or_null(food_visual_path)
	if node is CanvasItem:
		return node as CanvasItem

	return null


func _set_food_visual(food_visual: CanvasItem) -> void:
	_food_visual = food_visual
	if has_received_food:
		_show_food_visual()
	else:
		_hide_food_visual()


func _show_food_visual() -> void:
	if _food_visual == null:
		return

	_food_visual.visible = true


func _hide_food_visual() -> void:
	if _food_visual == null:
		return

	_food_visual.visible = false


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


func queue_walk_to(target_position: Vector2, start_delay_seconds: float = 0.0) -> void:
	_start_tweened_walk(target_position, start_delay_seconds)


func _move_toward_target() -> void:
	if _movement_tween != null:
		_stop_moving()
		return

	if not _has_target_position:
		_stop_moving()
		return

	var distance_to_target: float = global_position.distance_to(_target_position)
	if distance_to_target <= ARRIVAL_DISTANCE:
		_finish_movement()
		return

	var movement_direction: Vector2 = global_position.direction_to(_target_position)
	velocity = movement_direction * move_speed
	move_and_slide()


func _start_tweened_walk(target_position: Vector2, start_delay_seconds: float) -> void:
	_cancel_movement_tween()
	_movement_sequence += 1
	_target_position = target_position
	_has_target_position = true

	var movement_sequence: int = _movement_sequence
	_movement_tween = create_tween()
	_movement_tween.set_trans(Tween.TRANS_SINE)
	_movement_tween.set_ease(Tween.EASE_OUT)
	if start_delay_seconds > 0.0:
		_movement_tween.tween_interval(start_delay_seconds)
	_movement_tween.tween_callback(_begin_tweened_walk.bind(movement_sequence))
	_movement_tween.tween_property(self, "global_position", _target_position, QUEUE_MOVE_DURATION_SECONDS)
	_movement_tween.tween_callback(_finish_tweened_walk.bind(movement_sequence))


func _begin_tweened_walk(movement_sequence: int) -> void:
	if movement_sequence != _movement_sequence or not _has_target_position:
		return

	_set_state(CustomerState.WALKING)


func _finish_tweened_walk(movement_sequence: int) -> void:
	if movement_sequence != _movement_sequence:
		return

	_movement_tween = null
	_finish_movement()


func _cancel_movement_tween() -> void:
	_movement_sequence += 1
	if _movement_tween == null:
		return

	_movement_tween.kill()
	_movement_tween = null


func _get_queue_move_delay(queue_point: QueuePoint2D) -> float:
	if _queue_system == null or queue_point == null:
		return 0.0

	var queue_point_index: int = _queue_system.queue_points.find(queue_point)
	if queue_point_index <= 0:
		return 0.0

	return QUEUE_MOVE_FOLLOW_DELAY_SECONDS * float(queue_point_index)

func _finish_movement() -> void:
	var arrived_state: CustomerState = current_state
	global_position = _target_position
	_has_target_position = false
	_stop_moving()
	if arrived_state == CustomerState.WALKING:
		_set_state(CustomerState.WAITING)
	elif arrived_state == CustomerState.LEAVING:
		_finish_leaving()


func _finish_leaving() -> void:
	left.emit(self)
	if free_on_leave_completed:
		queue_free()
	else:
		_set_state(CustomerState.IDLE)


func _stop_moving() -> void:
	velocity = Vector2.ZERO


func _set_state(new_state: CustomerState) -> void:
	if current_state == new_state:
		return

	current_state = new_state
	state_changed.emit(current_state)


func _apply_random_visual_style() -> void:
	var skin_tone: Color = _get_random_color(SKIN_TONES)
	_shirt_visual.color = _get_random_color(BODY_COLORS)
	_head_visual.color = skin_tone
	_left_arm_visual.color = skin_tone
	_right_arm_visual.color = skin_tone
	_hair_visual.color = _get_random_color(HAIR_COLORS)
	_body_visual.scale = Vector2.ONE * randf_range(CUSTOMER_SCALE_MIN, CUSTOMER_SCALE_MAX)
	_apply_random_headwear()


func _apply_random_headwear() -> void:
	if randi() % 2 == 0:
		_hair_visual.polygon = PackedVector2Array([
			Vector2(-11, 2),
			Vector2(-7, -4),
			Vector2(0, -6),
			Vector2(8, -4),
			Vector2(12, 1),
			Vector2(8, 5),
			Vector2(1, 3),
			Vector2(-5, 6),
		])
	else:
		_hair_visual.polygon = PackedVector2Array([
			Vector2(-13, 2),
			Vector2(-10, -4),
			Vector2(10, -4),
			Vector2(13, 2),
			Vector2(8, 6),
			Vector2(-8, 6),
		])


func _get_random_color(colors: Array[Color]) -> Color:
	if colors.is_empty():
		return Color.WHITE

	return colors[randi() % colors.size()]
