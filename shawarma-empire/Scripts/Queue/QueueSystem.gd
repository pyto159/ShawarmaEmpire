extends Node
class_name QueueSystem

signal request_queued(request: QueueRequest)
signal request_cancelled(request: QueueRequest)
signal reservation_created(reservation: QueueReservation)
signal reservation_cancelled(reservation: QueueReservation)
signal reservation_completed(reservation: QueueReservation)
signal reservation_failed(requester: Node, reason: String)

const RESERVATION_FAILED_NO_POINT: String = "No queue point is available."
const RESERVATION_FAILED_DUPLICATE_REQUESTER: String = "Requester already has an active reservation."
const DEFAULT_REQUEST_PRIORITY: int = 0
const FIRST_SEQUENCE_NUMBER: int = 1

@export var auto_collect_child_queue_points: bool = true
@export var keep_full_queue: bool = true
@export var queue_capacity: int = 3

var queue_points: Array[QueuePoint2D] = []
var active_reservations: Array[QueueReservation] = []
var waiting_requests: Array[QueueRequest] = []

var _next_sequence_number: int = FIRST_SEQUENCE_NUMBER


func _ready() -> void:
	if auto_collect_child_queue_points:
		collect_child_queue_points()

	_process_waiting_requests()


func collect_child_queue_points() -> void:
	queue_points.clear()
	_add_queue_points_from_node(self)
	_sort_queue_points()
	_compact_active_reservations()
	_process_waiting_requests()


func add_queue_point(queue_point: QueuePoint2D) -> void:
	if queue_point == null or queue_points.has(queue_point):
		return

	queue_points.append(queue_point)
	_sort_queue_points()
	_compact_active_reservations()
	_process_waiting_requests()


func remove_queue_point(queue_point: QueuePoint2D) -> void:
	if queue_point == null:
		return

	var reservation: QueueReservation = get_reservation_for_queue_point(queue_point)
	queue_points.erase(queue_point)
	if reservation != null:
		reservation.cancel()
	else:
		_compact_active_reservations()
		_process_waiting_requests()


func try_reserve(requester: Node, request_priority: int = DEFAULT_REQUEST_PRIORITY) -> QueueReservation:
	if is_at_capacity():
		reservation_failed.emit(requester, RESERVATION_FAILED_NO_POINT)
		return null

	if has_active_reservation(requester) or has_waiting_request(requester):
		reservation_failed.emit(requester, RESERVATION_FAILED_DUPLICATE_REQUESTER)
		return null

	var request: QueueRequest = _create_request(requester, request_priority)
	waiting_requests.append(request)
	_sort_waiting_requests()
	request_queued.emit(request)
	return _process_waiting_requests_for_requester(requester)


func cancel_request(requester: Node) -> void:
	var waiting_request: QueueRequest = get_waiting_request_for_requester(requester)
	if waiting_request == null:
		return

	waiting_requests.erase(waiting_request)
	request_cancelled.emit(waiting_request)


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


func has_waiting_request(requester: Node) -> bool:
	return get_waiting_request_for_requester(requester) != null


func get_reservation_for_requester(requester: Node) -> QueueReservation:
	for reservation: QueueReservation in active_reservations:
		if reservation.requester == requester and reservation.is_active():
			return reservation

	return null


func get_waiting_request_for_requester(requester: Node) -> QueueRequest:
	for request: QueueRequest in waiting_requests:
		if request.requester == requester:
			return request

	return null


func get_reservation_for_queue_point(queue_point: QueuePoint2D) -> QueueReservation:
	for reservation: QueueReservation in active_reservations:
		if reservation.queue_point == queue_point and reservation.is_active():
			return reservation

	return null


func has_free_capacity() -> bool:
	return get_used_capacity() < get_effective_capacity()


func is_at_capacity() -> bool:
	return not has_free_capacity()


func get_used_capacity() -> int:
	return active_reservations.size() + waiting_requests.size()


func get_effective_capacity() -> int:
	if queue_capacity > 0:
		return queue_capacity

	return queue_points.size()


func get_available_queue_point() -> QueuePoint2D:
	for queue_point: QueuePoint2D in queue_points:
		if queue_point != null and queue_point.can_reserve():
			return queue_point

	return null


func _create_request(requester: Node, request_priority: int) -> QueueRequest:
	var request: QueueRequest = QueueRequest.new(requester, request_priority, _next_sequence_number)
	_next_sequence_number += 1
	return request


func _process_waiting_requests_for_requester(requester: Node) -> QueueReservation:
	_process_waiting_requests()
	var reservation: QueueReservation = get_reservation_for_requester(requester)
	if reservation != null:
		return reservation

	if not keep_full_queue:
		cancel_request(requester)
		reservation_failed.emit(requester, RESERVATION_FAILED_NO_POINT)

	return null


func _process_waiting_requests() -> void:
	_sort_waiting_requests()
	while not waiting_requests.is_empty() and active_reservations.size() < get_effective_capacity():
		var queue_point: QueuePoint2D = get_available_queue_point()
		if queue_point == null:
			return

		_register_request_at_queue_point(waiting_requests.pop_front(), queue_point)


func _register_request_at_queue_point(request: QueueRequest, queue_point: QueuePoint2D) -> void:
	var reservation: QueueReservation = QueueReservation.new(request.requester, queue_point, request.priority)
	if not queue_point.reserve(reservation):
		waiting_requests.push_front(request)
		reservation_failed.emit(request.requester, RESERVATION_FAILED_NO_POINT)
		return

	_register_reservation(reservation)


func _register_reservation(reservation: QueueReservation) -> void:
	active_reservations.append(reservation)
	_sort_active_reservations()
	reservation.cancelled.connect(_on_reservation_cancelled, CONNECT_ONE_SHOT)
	reservation.completed.connect(_on_reservation_completed, CONNECT_ONE_SHOT)
	reservation_created.emit(reservation)


func _on_reservation_cancelled(reservation: QueueReservation) -> void:
	_release_reservation(reservation)
	reservation_cancelled.emit(reservation)
	_compact_active_reservations()
	_process_waiting_requests()


func _on_reservation_completed(reservation: QueueReservation) -> void:
	_release_reservation(reservation)
	reservation_completed.emit(reservation)
	_compact_active_reservations()
	_process_waiting_requests()


func _release_reservation(reservation: QueueReservation) -> void:
	active_reservations.erase(reservation)
	if reservation.queue_point != null:
		reservation.queue_point.release(reservation)


func _compact_active_reservations() -> void:
	_sort_active_reservations()
	for reservation_index: int in range(active_reservations.size()):
		var reservation: QueueReservation = active_reservations[reservation_index]
		if reservation_index >= queue_points.size():
			reservation.cancel()
			continue

		_move_reservation_to_queue_point(reservation, queue_points[reservation_index])


func _move_reservation_to_queue_point(reservation: QueueReservation, queue_point: QueuePoint2D) -> void:
	if reservation.queue_point == queue_point:
		return

	var old_queue_point: QueuePoint2D = reservation.queue_point
	if old_queue_point != null:
		old_queue_point.release(reservation)

	if queue_point.reserve(reservation):
		reservation.move_to_queue_point(queue_point)


func _sort_queue_points() -> void:
	queue_points.sort_custom(_compare_queue_points)


func _sort_active_reservations() -> void:
	active_reservations.sort_custom(_compare_reservations)


func _sort_waiting_requests() -> void:
	waiting_requests.sort_custom(_compare_requests)


func _compare_queue_points(left: QueuePoint2D, right: QueuePoint2D) -> bool:
	return left.priority > right.priority


func _compare_reservations(left: QueueReservation, right: QueueReservation) -> bool:
	if left.priority == right.priority:
		return _get_queue_point_index(left.queue_point) < _get_queue_point_index(right.queue_point)

	return left.priority > right.priority


func _compare_requests(left: QueueRequest, right: QueueRequest) -> bool:
	if left.priority == right.priority:
		return left.sequence_number < right.sequence_number

	return left.priority > right.priority


func _get_queue_point_index(queue_point: QueuePoint2D) -> int:
	var queue_point_index: int = queue_points.find(queue_point)
	if queue_point_index == -1:
		return queue_points.size()

	return queue_point_index


func _add_queue_points_from_node(node: Node) -> void:
	for child: Node in node.get_children():
		if child is QueuePoint2D:
			var queue_point: QueuePoint2D = child as QueuePoint2D
			if not queue_points.has(queue_point):
				queue_points.append(queue_point)

		_add_queue_points_from_node(child)
