extends CookingStation
class_name CookingStand

var accepted_order: Order
var completed_order: Order


func accept_order(order: Order) -> bool:
	if order == null or order.is_completed or has_active_order():
		return false

	accepted_order = order
	completed_order = null
	return true


func has_active_order() -> bool:
	return accepted_order != null or is_cooking()


func has_completed_order() -> bool:
	return completed_order != null and completed_order.is_completed


func can_cook() -> bool:
	return accepted_order != null and can_start_order(accepted_order)


func start_cooking() -> bool:
	if not can_cook():
		return false

	var order_to_cook: Order = accepted_order
	accepted_order = null
	return start_order(order_to_cook)


func complete_cooking() -> bool:
	if accepted_order != null:
		var order_to_complete: Order = accepted_order
		accepted_order = null
		return _complete_order(order_to_complete)

	if current_order == null:
		return false

	_complete_current_order()
	return true


func deliver_completed_order(customer: Customer, leave_target_position: Vector2) -> bool:
	if customer == null or not has_completed_order():
		return false

	if not customer.receive_completed_order(completed_order, leave_target_position):
		return false

	completed_order = null
	return true


func _complete_current_order() -> void:
	var order_to_complete: Order = current_order
	_clear_current_order()
	_complete_order(order_to_complete)


func _complete_order(order: Order) -> bool:
	if order == null or not order.complete():
		return false

	completed_order = order
	cooking_completed.emit(completed_order)
	return true
