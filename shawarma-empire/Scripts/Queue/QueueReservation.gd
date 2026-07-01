extends RefCounted
class_name QueueReservation

signal cancelled(reservation: QueueReservation)
signal completed(reservation: QueueReservation)
signal queue_point_changed(reservation: QueueReservation, queue_point: QueuePoint2D)

var requester: Node
var queue_point: QueuePoint2D
var priority: int
var is_cancelled: bool = false
var is_completed: bool = false


func _init(new_requester: Node, new_queue_point: QueuePoint2D, new_priority: int) -> void:
	requester = new_requester
	queue_point = new_queue_point
	priority = new_priority


func cancel() -> void:
	if is_cancelled or is_completed:
		return

	is_cancelled = true
	cancelled.emit(self)


func complete() -> void:
	if is_cancelled or is_completed:
		return

	is_completed = true
	completed.emit(self)


func is_active() -> bool:
	return not is_cancelled and not is_completed


func move_to_queue_point(new_queue_point: QueuePoint2D) -> void:
	if queue_point == new_queue_point:
		return

	queue_point = new_queue_point
	queue_point_changed.emit(self, queue_point)
