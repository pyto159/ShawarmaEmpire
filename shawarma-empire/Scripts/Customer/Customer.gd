class_name Customer
extends Node2D
## Gameplay customer actor.
##
## A customer moves through an isolated finite state machine: idle, walking,
## waiting, and leaving. Ordering and economy are intentionally not included.

signal departed(customer: Customer)

const DEFAULT_MOVE_SPEED: float = 120.0
const ARRIVAL_DISTANCE: float = 4.0

@export var move_speed: float = DEFAULT_MOVE_SPEED
@export var waiting_point: Vector2 = Vector2.ZERO
@export var exit_point: Vector2 = Vector2.ZERO


func move_toward_point(target_point: Vector2, delta: float) -> bool:
	global_position = global_position.move_toward(target_point, move_speed * delta)
	return global_position.distance_to(target_point) <= ARRIVAL_DISTANCE


func leave_queue() -> void:
	departed.emit(self)
	queue_free()
