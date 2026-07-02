extends Node2D
class_name PreparationTable

const COMPLETED_HIDE_DELAY_SECONDS: float = 0.45
const LAVASH_STEP_PROGRESS: float = 0.0
const MEAT_STEP_PROGRESS: float = 0.2
const SAUCE_STEP_PROGRESS: float = 0.4
const ROLL_STEP_PROGRESS: float = 0.6
const COMPLETE_STEP_PROGRESS: float = 0.8

@export var cooking_stand_path: NodePath

@onready var _title_label: Label = $Panel/TitleLabel
@onready var _status_label: Label = $Panel/StatusLabel
@onready var _lavash: ColorRect = $Panel/Board/Lavash
@onready var _meat: ColorRect = $Panel/Board/Meat
@onready var _sauce: ColorRect = $Panel/Board/GarlicSauce
@onready var _rolled_shawarma: ColorRect = $Panel/Board/RolledShawarma
@onready var _complete_label: Label = $Panel/Board/CompleteLabel

var _cooking_stand: CookingStand
var _hide_timer: Timer = Timer.new()


func _ready() -> void:
	visible = false
	_configure_hide_timer()
	_resolve_configured_cooking_stand()
	_connect_cooking_stand_signals()
	_show_progress_step(LAVASH_STEP_PROGRESS)


func _exit_tree() -> void:
	_disconnect_cooking_stand_signals()


func set_cooking_stand(cooking_stand: CookingStand) -> void:
	if _cooking_stand == cooking_stand:
		return

	_disconnect_cooking_stand_signals()
	_cooking_stand = cooking_stand
	_connect_cooking_stand_signals()
	_reset_table()


func _configure_hide_timer() -> void:
	_hide_timer.one_shot = true
	_hide_timer.timeout.connect(_on_hide_timer_timeout)
	add_child(_hide_timer)


func _resolve_configured_cooking_stand() -> void:
	if cooking_stand_path.is_empty():
		return

	var cooking_node: Node = get_node_or_null(cooking_stand_path)
	if cooking_node is CookingStand:
		_cooking_stand = cooking_node as CookingStand


func _connect_cooking_stand_signals() -> void:
	if _cooking_stand == null:
		return

	if not _cooking_stand.cooking_started.is_connected(_on_cooking_started):
		_cooking_stand.cooking_started.connect(_on_cooking_started)

	if not _cooking_stand.cooking_progress_changed.is_connected(_on_cooking_progress_changed):
		_cooking_stand.cooking_progress_changed.connect(_on_cooking_progress_changed)

	if not _cooking_stand.cooking_completed.is_connected(_on_cooking_completed):
		_cooking_stand.cooking_completed.connect(_on_cooking_completed)

	if not _cooking_stand.cooking_cancelled.is_connected(_on_cooking_cancelled):
		_cooking_stand.cooking_cancelled.connect(_on_cooking_cancelled)


func _disconnect_cooking_stand_signals() -> void:
	if _cooking_stand == null:
		return

	if _cooking_stand.cooking_started.is_connected(_on_cooking_started):
		_cooking_stand.cooking_started.disconnect(_on_cooking_started)

	if _cooking_stand.cooking_progress_changed.is_connected(_on_cooking_progress_changed):
		_cooking_stand.cooking_progress_changed.disconnect(_on_cooking_progress_changed)

	if _cooking_stand.cooking_completed.is_connected(_on_cooking_completed):
		_cooking_stand.cooking_completed.disconnect(_on_cooking_completed)

	if _cooking_stand.cooking_cancelled.is_connected(_on_cooking_cancelled):
		_cooking_stand.cooking_cancelled.disconnect(_on_cooking_cancelled)


func _show_progress_step(progress: float) -> void:
	var safe_progress: float = clampf(progress, 0.0, 1.0)
	var is_rolled: bool = safe_progress >= ROLL_STEP_PROGRESS
	_lavash.visible = not is_rolled and safe_progress >= LAVASH_STEP_PROGRESS
	_meat.visible = not is_rolled and safe_progress >= MEAT_STEP_PROGRESS
	_sauce.visible = not is_rolled and safe_progress >= SAUCE_STEP_PROGRESS
	_rolled_shawarma.visible = is_rolled
	_complete_label.visible = safe_progress >= COMPLETE_STEP_PROGRESS
	_update_status_label(safe_progress)


func _update_status_label(progress: float) -> void:
	if progress >= COMPLETE_STEP_PROGRESS:
		_status_label.text = "Ready shawarma!"
	elif progress >= ROLL_STEP_PROGRESS:
		_status_label.text = "Rolling wrap"
	elif progress >= SAUCE_STEP_PROGRESS:
		_status_label.text = "Adding garlic sauce"
	elif progress >= MEAT_STEP_PROGRESS:
		_status_label.text = "Adding chicken"
	else:
		_status_label.text = "Laying lavash"


func _reset_table() -> void:
	_hide_timer.stop()
	visible = false
	_show_progress_step(LAVASH_STEP_PROGRESS)


func _on_cooking_started(_order: Order) -> void:
	_hide_timer.stop()
	_title_label.text = "Preparation"
	_show_progress_step(LAVASH_STEP_PROGRESS)
	visible = true


func _on_cooking_progress_changed(_order: Order, _remaining_seconds: float, progress: float) -> void:
	_hide_timer.stop()
	visible = true
	_show_progress_step(progress)


func _on_cooking_completed(_order: Order) -> void:
	_show_progress_step(COMPLETE_STEP_PROGRESS)
	visible = true
	_hide_timer.start(COMPLETED_HIDE_DELAY_SECONDS)


func _on_cooking_cancelled(_order: Order) -> void:
	_reset_table()


func _on_hide_timer_timeout() -> void:
	_reset_table()
