extends Node2D
class_name PreparationTable

const COMPLETED_HIDE_DELAY_SECONDS: float = 0.45
const LAVASH_STEP_PROGRESS: float = 0.0
const MEAT_STEP_PROGRESS: float = 0.2
const SAUCE_STEP_PROGRESS: float = 0.4
const ROLL_STEP_PROGRESS: float = 0.6
const COMPLETE_STEP_PROGRESS: float = 0.8
const INGREDIENT_APPEAR_SCALE: Vector2 = Vector2(0.7, 0.7)
const INGREDIENT_SETTLE_SCALE: Vector2 = Vector2.ONE
const INGREDIENT_BOUNCE_SCALE: Vector2 = Vector2(1.08, 1.08)
const INGREDIENT_APPEAR_SECONDS: float = 0.09
const INGREDIENT_SETTLE_SECONDS: float = 0.05
const INGREDIENT_DELAY_SECONDS: float = 0.025
const INGREDIENT_ROTATION_DEGREES: float = 5.0
const SMOKE_FLOAT_PIXELS: float = 16.0
const SMOKE_PULSE_SECONDS: float = 0.8


@export var cooking_stand_path: NodePath

@onready var _title_label: Label = $Panel/TitleLabel
@onready var _status_label: Label = $Panel/StatusLabel
@onready var _lavash: ColorRect = $Panel/Board/Lavash
@onready var _meat: ColorRect = $Panel/Board/Meat
@onready var _sauce: ColorRect = $Panel/Board/GarlicSauce
@onready var _tomato: ColorRect = $Panel/Board/TomatoSlices
@onready var _cucumber: ColorRect = $Panel/Board/CucumberSlices
@onready var _rolled_shawarma: ColorRect = $Panel/Board/RolledShawarma
@onready var _complete_label: Label = $Panel/Board/CompleteLabel
@onready var _smoke_particles: Array[ColorRect] = [$Panel/Board/SmokeOne, $Panel/Board/SmokeTwo]

var _cooking_stand: CookingStand
var _hide_timer: Timer = Timer.new()
var _ingredient_tweens: Dictionary = {}
var _smoke_tween: Tween


func _ready() -> void:
	visible = false
	_configure_hide_timer()
	_resolve_configured_cooking_stand()
	_connect_cooking_stand_signals()
	_configure_ingredient_pivots()
	_hide_all_ingredients()


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


func _configure_ingredient_pivots() -> void:
	for ingredient_node: Control in [_lavash, _meat, _sauce, _tomato, _cucumber, _rolled_shawarma]:
		ingredient_node.pivot_offset = ingredient_node.size * 0.5


func _show_progress_step(progress: float, animate_ingredients: bool = true) -> void:
	var safe_progress: float = clampf(progress, 0.0, 1.0)
	var is_rolled: bool = safe_progress >= ROLL_STEP_PROGRESS
	_set_ingredient_visible(_lavash, not is_rolled and safe_progress >= LAVASH_STEP_PROGRESS, 0, animate_ingredients)
	_set_ingredient_visible(_meat, not is_rolled and safe_progress >= MEAT_STEP_PROGRESS, 1, animate_ingredients)
	_set_ingredient_visible(_sauce, not is_rolled and safe_progress >= SAUCE_STEP_PROGRESS, 2, animate_ingredients)
	_set_ingredient_visible(_tomato, not is_rolled and safe_progress >= SAUCE_STEP_PROGRESS, 3, animate_ingredients)
	_set_ingredient_visible(_cucumber, not is_rolled and safe_progress >= SAUCE_STEP_PROGRESS, 4, animate_ingredients)
	_set_ingredient_visible(_rolled_shawarma, is_rolled, 5, animate_ingredients)
	_set_smoke_visible(safe_progress >= MEAT_STEP_PROGRESS and safe_progress < COMPLETE_STEP_PROGRESS)
	_complete_label.visible = safe_progress >= COMPLETE_STEP_PROGRESS
	_update_status_label(safe_progress)


func _set_ingredient_visible(ingredient_node: Control, should_show: bool, sequence_index: int, animate_ingredient: bool) -> void:
	if not should_show:
		_stop_ingredient_tween(ingredient_node)
		_reset_ingredient_transform(ingredient_node)
		ingredient_node.visible = false
		return

	if ingredient_node.visible:
		return

	ingredient_node.visible = true
	if animate_ingredient:
		_play_ingredient_appear_animation(ingredient_node, sequence_index)
	else:
		_reset_ingredient_transform(ingredient_node)


func _play_ingredient_appear_animation(ingredient_node: Control, sequence_index: int) -> void:
	_stop_ingredient_tween(ingredient_node)
	ingredient_node.scale = INGREDIENT_APPEAR_SCALE
	ingredient_node.rotation_degrees = _get_ingredient_start_rotation(sequence_index)

	var tween: Tween = create_tween()
	_ingredient_tweens[ingredient_node] = tween
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	if sequence_index > 0:
		tween.tween_interval(INGREDIENT_DELAY_SECONDS * sequence_index)
	tween.tween_property(ingredient_node, "scale", INGREDIENT_BOUNCE_SCALE, INGREDIENT_APPEAR_SECONDS)
	tween.parallel().tween_property(ingredient_node, "rotation_degrees", 0.0, INGREDIENT_APPEAR_SECONDS)
	tween.tween_property(ingredient_node, "scale", INGREDIENT_SETTLE_SCALE, INGREDIENT_SETTLE_SECONDS)
	tween.finished.connect(_on_ingredient_tween_finished.bind(ingredient_node))


func _get_ingredient_start_rotation(sequence_index: int) -> float:
	if sequence_index % 2 == 0:
		return -INGREDIENT_ROTATION_DEGREES

	return INGREDIENT_ROTATION_DEGREES


func _stop_ingredient_tween(ingredient_node: Control) -> void:
	if not _ingredient_tweens.has(ingredient_node):
		return

	var tween: Tween = _ingredient_tweens[ingredient_node]
	if tween != null and tween.is_valid():
		tween.kill()
	_ingredient_tweens.erase(ingredient_node)


func _reset_ingredient_transform(ingredient_node: Control) -> void:
	ingredient_node.scale = INGREDIENT_SETTLE_SCALE
	ingredient_node.rotation_degrees = 0.0


func _hide_all_ingredients() -> void:
	for ingredient_node: Control in [_lavash, _meat, _sauce, _tomato, _cucumber, _rolled_shawarma]:
		_stop_ingredient_tween(ingredient_node)
		_reset_ingredient_transform(ingredient_node)
		ingredient_node.visible = false
	_complete_label.visible = false
	_set_smoke_visible(false)


func _on_ingredient_tween_finished(ingredient_node: Control) -> void:
	_ingredient_tweens.erase(ingredient_node)
	_reset_ingredient_transform(ingredient_node)


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
	_hide_all_ingredients()
	_update_status_label(LAVASH_STEP_PROGRESS)


func _on_cooking_started(_order: Order) -> void:
	_hide_timer.stop()
	_title_label.text = "Preparation"
	visible = true
	_show_progress_step(LAVASH_STEP_PROGRESS)


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


func _set_smoke_visible(should_show: bool) -> void:
	for smoke_particle: ColorRect in _smoke_particles:
		smoke_particle.visible = should_show
	if should_show and (_smoke_tween == null or not _smoke_tween.is_valid()):
		_start_smoke_animation()
	elif not should_show:
		_stop_smoke_animation()


func _start_smoke_animation() -> void:
	_stop_smoke_animation()
	_smoke_tween = create_tween()
	_smoke_tween.set_loops()
	for smoke_particle: ColorRect in _smoke_particles:
		smoke_particle.position = Vector2.ZERO
		smoke_particle.modulate.a = 0.45
		_smoke_tween.parallel().tween_property(smoke_particle, "position:y", -SMOKE_FLOAT_PIXELS, SMOKE_PULSE_SECONDS).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		_smoke_tween.parallel().tween_property(smoke_particle, "modulate:a", 0.0, SMOKE_PULSE_SECONDS).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_smoke_tween.tween_callback(_reset_smoke_particles)


func _reset_smoke_particles() -> void:
	for smoke_particle: ColorRect in _smoke_particles:
		smoke_particle.position = Vector2.ZERO
		smoke_particle.modulate.a = 0.45


func _stop_smoke_animation() -> void:
	if _smoke_tween != null:
		_smoke_tween.kill()
		_smoke_tween = null
	_reset_smoke_particles()
