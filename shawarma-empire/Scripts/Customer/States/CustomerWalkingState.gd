class_name CustomerWalkingState
extends State
## Customer walking state.
##
## Moves the customer from the spawn point to the stand's waiting point.

@export var waiting_state: State


func update(context: Node, delta: float) -> void:
	var customer: Customer = context as Customer
	if customer == null:
		return

	if customer.move_toward_point(customer.waiting_point, delta):
		state_machine.change_state(waiting_state)
