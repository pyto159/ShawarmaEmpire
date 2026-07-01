class_name CustomerLeavingState
extends State
## Customer leaving state.
##
## Moves the customer away from the stand and notifies the spawner when the
## customer has fully exited the active gameplay loop.


func update(context: Node, delta: float) -> void:
	var customer: Customer = context as Customer
	if customer == null:
		return

	if customer.move_toward_point(customer.exit_point, delta):
		customer.leave_queue()
