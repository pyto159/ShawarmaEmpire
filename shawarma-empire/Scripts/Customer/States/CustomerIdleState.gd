class_name CustomerIdleState
extends State
## Customer idle state.
##
## This short entry state lets spawned customers initialize before walking to
## the stand.

@export var walking_state: State


func enter(_context: Node) -> void:
	state_machine.change_state(walking_state)
