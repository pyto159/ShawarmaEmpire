extends Node2D
class_name CookingStation

signal cooking_started(order: Order)
signal cooking_progress_changed(order: Order, remaining_seconds: float, progress: float)
signal cooking_completed(order: Order)
signal cooking_cancelled(order: Order)

const DEFAULT_COOKING_SPEED_MULTIPLIER: float = 1.0
const MINIMUM_COOKING_SPEED_MULTIPLIER: float = 0.01
const DEFAULT_PREPARATION_SECONDS: float = 0.0
const COMPLETE_PROGRESS: float = 1.0
const EMPTY_PROGRESS: float = 0.0

@export var auto_process_order: bool = true
@export var cooking_speed_multiplier: float = DEFAULT_COOKING_SPEED_MULTIPLIER

var current_order: Order
var remaining_seconds: float = DEFAULT_PREPARATION_SECONDS
var total_seconds: float = DEFAULT_PREPARATION_SECONDS


func _process(delta: float) -> void:
	if not auto_process_order or current_order == null:
		return

	advance_cooking(delta)


func can_start_order(order: Order) -> bool:
	return current_order == null and order != null and not order.is_completed


func start_order(order: Order) -> bool:
	if not can_start_order(order):
		return false

	current_order = order
	total_seconds = _get_modified_preparation_time(order.preparation_time)
	remaining_seconds = total_seconds
	cooking_started.emit(current_order)
	_emit_progress_changed()

	if is_zero_approx(total_seconds):
		_complete_current_order()

	return true


func advance_cooking(delta: float) -> void:
	if current_order == null:
		return

	remaining_seconds = max(remaining_seconds - delta, DEFAULT_PREPARATION_SECONDS)
	_emit_progress_changed()

	if is_zero_approx(remaining_seconds):
		_complete_current_order()


func get_modified_preparation_time(base_preparation_time: float) -> float:
	return _get_modified_preparation_time(base_preparation_time)


func cancel_order() -> void:
	if current_order == null:
		return

	var cancelled_order: Order = current_order
	_clear_current_order()
	cooking_cancelled.emit(cancelled_order)


func get_progress() -> float:
	if current_order == null:
		return EMPTY_PROGRESS

	if is_zero_approx(total_seconds):
		return COMPLETE_PROGRESS

	return clampf((total_seconds - remaining_seconds) / total_seconds, EMPTY_PROGRESS, COMPLETE_PROGRESS)


func is_cooking() -> bool:
	return current_order != null


func _get_modified_preparation_time(base_preparation_time: float) -> float:
	var safe_speed_multiplier: float = max(cooking_speed_multiplier, MINIMUM_COOKING_SPEED_MULTIPLIER)
	return max(base_preparation_time * safe_speed_multiplier, DEFAULT_PREPARATION_SECONDS)


func _complete_current_order() -> void:
	var completed_order: Order = current_order
	_clear_current_order()
	completed_order.complete()
	cooking_completed.emit(completed_order)


func _clear_current_order() -> void:
	current_order = null
	remaining_seconds = DEFAULT_PREPARATION_SECONDS
	total_seconds = DEFAULT_PREPARATION_SECONDS


func _emit_progress_changed() -> void:
	cooking_progress_changed.emit(current_order, remaining_seconds, get_progress())
