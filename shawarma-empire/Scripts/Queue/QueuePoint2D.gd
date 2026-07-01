extends Marker2D
class_name QueuePoint2D

signal reservation_changed(is_reserved: bool)

const DEFAULT_PRIORITY: int = 0

@export var is_enabled: bool = true
@export var priority: int = DEFAULT_PRIORITY

var reservation: QueueReservation


func can_reserve() -> bool:
	return is_enabled and reservation == null


func reserve(new_reservation: QueueReservation) -> bool:
	if new_reservation == null or not can_reserve():
		return false

	reservation = new_reservation
	reservation_changed.emit(true)
	return true


func release(active_reservation: QueueReservation) -> void:
	if reservation != active_reservation:
		return

	reservation = null
	reservation_changed.emit(false)
