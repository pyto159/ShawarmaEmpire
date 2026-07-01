extends Node
class_name QueueSystem

signal reservation_created(reservation: QueueReservation)
signal reservation_cancelled(reservation: QueueReservation)
signal reservation_completed(reservation: QueueReservation)
signal reservation_failed(requester: Node, reason: String)

const RESERVATION_FAILED_NO_POINT: String = "No queue point is available."
const RESERVATION_FAILED_DUPLICATE_REQUESTER: String = "Requester already has an active reservation."
const DEFAULT_REQUEST_PRIORITY: int = 0

@export var auto_collect_child_queue_points: bool = true

var queue_points: Array[QueuePoint2D] = []
var active_reservations: Array[QueueReservation] = []


func _ready() -> void:
	if auto_collect_child_queue_points:
		collect_child_queue_points()


func collect_child_queue_points() -> void:
	queue_points.clear()
	_add_queue_points_from_node(self)
	_sort_queue_points()


func add_queue_point(queue_point: QueuePoint2D) -> void:
	if queue_point == null or queue_points.has(queue_point):
		return

	queue_points.append(queue_point)
	_sort_queue_points()


func remove_queue_point(queue_point: QueuePoint2D) -> void:
	if queue_point == null:
		return

	var reservation: QueueReservation = get_reservation_for_queue_point(queue_point)
	if reservation != null:
		reservation.cancel()

	queue_points.erase(queue_point)


func try_reserve(requester: Node, request_priority: int = DEFAULT_REQUEST_PRIORITY) -> QueueReservation:
	if requester != null and has_active_reservation(requester):
		reservation_failed.emit(requester, RESERVATION_FAILED_DUPLICATE_REQUESTER)
		return null

	var queue_point: QueuePoint2D = get_available_queue_point()
	if queue_point == null:
		reservation_failed.emit(requester, RESERVATION_FAILED_NO_POINT)
		return null

	var reservation: QueueReservation = QueueReservation.new(requester, queue_point, request_priority)
	if not queue_point.reserve(reservation):
		reservation_failed.emit(requester, RESERVATION_FAILED_NO_POINT)
		return null

	_register_reservation(reservation)
	return reservation


func cancel_reservation(reservation: QueueReservation) -> void:
	if reservation == null:
		return

	reservation.cancel()


func complete_reservation(reservation: QueueReservation) -> void:
	if reservation == null:
		return

	reservation.complete()


func has_active_reservation(requester: Node) -> bool:
	return get_reservation_for_requester(requester) != null


func get_reservation_for_requester(requester: Node) -> QueueReservation:
	for reservation: QueueReservation in active_reservations:
		if reservation.requester == requester and reservation.is_active():
			return reservation

	return null


func get_reservation_for_queue_point(queue_point: QueuePoint2D) -> QueueReservation:
	for reservation: QueueReservation in active_reservations:
		if reservation.queue_point == queue_point and reservation.is_active():
			return reservation

	return null


func get_available_queue_point() -> QueuePoint2D:
	for queue_point: QueuePoint2D in queue_points:
		if queue_point != null and queue_point.can_reserve():
			return queue_point

	return null


func _register_reservation(reservation: QueueReservation) -> void:
	active_reservations.append(reservation)
	reservation.cancelled.connect(_on_reservation_cancelled, CONNECT_ONE_SHOT)
	reservation.completed.connect(_on_reservation_completed, CONNECT_ONE_SHOT)
	reservation_created.emit(reservation)


func _on_reservation_cancelled(reservation: QueueReservation) -> void:
	_release_reservation(reservation)
	reservation_cancelled.emit(reservation)


func _on_reservation_completed(reservation: QueueReservation) -> void:
	_release_reservation(reservation)
	reservation_completed.emit(reservation)


func _release_reservation(reservation: QueueReservation) -> void:
	active_reservations.erase(reservation)
	if reservation.queue_point != null:
		reservation.queue_point.release(reservation)


func _sort_queue_points() -> void:
	queue_points.sort_custom(_compare_queue_points)


func _compare_queue_points(left: QueuePoint2D, right: QueuePoint2D) -> bool:
	return left.priority > right.priority


func _add_queue_points_from_node(node: Node) -> void:
	for child: Node in node.get_children():
		if child is QueuePoint2D:
			add_queue_point(child as QueuePoint2D)

		_add_queue_points_from_node(child)
