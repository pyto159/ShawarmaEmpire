class_name StateMachine
extends Node
## Reusable finite state machine component.
##
## The state machine owns state transitions while the parent node remains the
## behavior context passed into each state's lifecycle methods.

@export var initial_state: State

var current_state: State
var context: Node


func _ready() -> void:
	context = get_parent()
	_register_states()
	change_state(initial_state)


func _process(delta: float) -> void:
	if current_state == null:
		return

	current_state.update(context, delta)


func change_state(next_state: State) -> void:
	if next_state == null or next_state == current_state:
		return

	if current_state != null:
		current_state.exit(context)

	current_state = next_state
	current_state.enter(context)


func _register_states() -> void:
	for child: Node in get_children():
		var state: State = child as State
		if state != null:
			state.state_machine = self
