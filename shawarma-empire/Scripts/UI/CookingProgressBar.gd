extends ProgressBar
class_name CookingProgressBar

const COMPLETE_PROGRESS_VALUE: float = 100.0
const EMPTY_PROGRESS_VALUE: float = 0.0
const PROGRESS_SCALE: float = 100.0
const HIDE_DELAY_SECONDS: float = 0.25
const MINIMUM_WIDTH: float = 220.0
const MINIMUM_HEIGHT: float = 18.0

@export var cooking_stand_path: NodePath

var _cooking_stand: CookingStand
var _hide_timer: Timer = Timer.new()


func _ready() -> void:
	custom_minimum_size = Vector2(MINIMUM_WIDTH, MINIMUM_HEIGHT)
	min_value = EMPTY_PROGRESS_VALUE
	max_value = COMPLETE_PROGRESS_VALUE
	value = EMPTY_PROGRESS_VALUE
	show_percentage = true
	visible = false
	_configure_hide_timer()
	_resolve_configured_cooking_stand()
	_connect_cooking_stand_signals()


func _exit_tree() -> void:
	_disconnect_cooking_stand_signals()


func set_cooking_stand(cooking_stand: CookingStand) -> void:
	if _cooking_stand == cooking_stand:
		return

	_disconnect_cooking_stand_signals()
	_cooking_stand = cooking_stand
	_connect_cooking_stand_signals()
	_reset_display()


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


func _show_progress(progress: float) -> void:
	_hide_timer.stop()
	value = clampf(progress, 0.0, 1.0) * PROGRESS_SCALE
	visible = true


func _hide_after_delay() -> void:
	value = COMPLETE_PROGRESS_VALUE
	_hide_timer.start(HIDE_DELAY_SECONDS)


func _reset_display() -> void:
	_hide_timer.stop()
	value = EMPTY_PROGRESS_VALUE
	visible = false


func _on_cooking_started(_order: Order) -> void:
	_show_progress(0.0)


func _on_cooking_progress_changed(_order: Order, _remaining_seconds: float, progress: float) -> void:
	_show_progress(progress)


func _on_cooking_completed(_order: Order) -> void:
	_hide_after_delay()


func _on_cooking_cancelled(_order: Order) -> void:
	_reset_display()


func _on_hide_timer_timeout() -> void:
	_reset_display()
