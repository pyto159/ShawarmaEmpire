class_name State
extends Node
## Base finite state machine state.
##
## Concrete states override lifecycle methods and request transitions through
## the state machine instead of directly controlling sibling states.

var state_machine: StateMachine


func enter(_context: Node) -> void:
	pass


func exit(_context: Node) -> void:
	pass


func update(_context: Node, _delta: float) -> void:
	pass
