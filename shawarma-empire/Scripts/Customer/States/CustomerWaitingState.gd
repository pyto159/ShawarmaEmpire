class_name CustomerWaitingState
extends State
## Customer waiting state.
##
## Keeps the customer at the counter briefly, proving the loop without adding
## ordering, money, or upgrade mechanics.

const DEFAULT_WAIT_SECONDS: float = 2.0

@export var leaving_state: State
@export var wait_seconds: float = DEFAULT_WAIT_SECONDS

var remaining_seconds: float = 0.0


func enter(_context: Node) -> void:
	remaining_seconds = wait_seconds


func update(_context: Node, delta: float) -> void:
	remaining_seconds -= delta
	if remaining_seconds <= 0.0:
		state_machine.change_state(leaving_state)
