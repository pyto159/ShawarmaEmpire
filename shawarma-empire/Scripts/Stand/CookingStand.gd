extends CookingStation
class_name CookingStand

var accepted_order: Order


func accept_order(order: Order) -> bool:
	if order == null or order.is_completed or has_active_order():
		return false

	accepted_order = order
	return true


func has_active_order() -> bool:
	return accepted_order != null or is_cooking()


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
		var completed_order: Order = accepted_order
		accepted_order = null
		completed_order.complete()
		cooking_completed.emit(completed_order)
		return true

	if current_order == null:
		return false

	_complete_current_order()
	return true
