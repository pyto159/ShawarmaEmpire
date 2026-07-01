extends CharacterBody2D

signal state_changed(new_state: CustomerState)

const DEFAULT_MOVE_SPEED: float = 90.0
const ARRIVAL_DISTANCE: float = 4.0

enum CustomerState {
	IDLE,
	WALKING,
	WAITING,
	LEAVING,
}

@export var move_speed: float = DEFAULT_MOVE_SPEED

var current_state: CustomerState = CustomerState.IDLE
var _target_position: Vector2 = Vector2.ZERO
var _has_target_position: bool = false


func _ready() -> void:
	_target_position = global_position


func _physics_process(_delta: float) -> void:
	match current_state:
		CustomerState.IDLE:
			_stop_moving()
		CustomerState.WALKING, CustomerState.LEAVING:
			_move_toward_target()
		CustomerState.WAITING:
			_stop_moving()


func walk_to(target_position: Vector2) -> void:
	_target_position = target_position
	_has_target_position = true
	_set_state(CustomerState.WALKING)


func wait_for_service() -> void:
	_has_target_position = false
	_set_state(CustomerState.WAITING)


func leave_to(target_position: Vector2) -> void:
	_target_position = target_position
	_has_target_position = true
	_set_state(CustomerState.LEAVING)


func set_idle() -> void:
	_has_target_position = false
	_set_state(CustomerState.IDLE)


func _move_toward_target() -> void:
	if not _has_target_position:
		_stop_moving()
		return

	var distance_to_target: float = global_position.distance_to(_target_position)
	if distance_to_target <= ARRIVAL_DISTANCE:
		global_position = _target_position
		_has_target_position = false
		_stop_moving()
		if current_state == CustomerState.WALKING:
			_set_state(CustomerState.WAITING)
		return

	var movement_direction: Vector2 = global_position.direction_to(_target_position)
	velocity = movement_direction * move_speed
	move_and_slide()


func _stop_moving() -> void:
	velocity = Vector2.ZERO


func _set_state(new_state: CustomerState) -> void:
	if current_state == new_state:
		return

	current_state = new_state
	state_changed.emit(current_state)
