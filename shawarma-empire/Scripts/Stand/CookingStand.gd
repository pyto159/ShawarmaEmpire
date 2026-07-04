extends CookingStation
class_name CookingStand

const FLAME_INTENSITY_STEP: float = 0.12
const FLAME_SCALE_STEP: float = 0.08

@export var flame_visual_path: NodePath

var accepted_order: Order
var completed_order: Order
var _flame_visual: CanvasItem
var _base_flame_modulate: Color = Color.WHITE
var _base_flame_scale: Vector2 = Vector2.ONE


func _ready() -> void:
	_resolve_flame_visual()
	_apply_cooking_speed_multiplier()
	_apply_grill_visual_feedback()
	if not GameManager.upgrades_changed.is_connected(_on_upgrades_changed):
		GameManager.upgrades_changed.connect(_on_upgrades_changed)


func _exit_tree() -> void:
	if GameManager.upgrades_changed.is_connected(_on_upgrades_changed):
		GameManager.upgrades_changed.disconnect(_on_upgrades_changed)


func accept_order(order: Order) -> bool:
	if order == null or order.is_completed or has_active_order():
		return false

	accepted_order = order
	completed_order = null
	return true


func has_active_order() -> bool:
	return accepted_order != null or is_cooking()


func has_completed_order() -> bool:
	return completed_order != null and completed_order.is_completed


func can_cook() -> bool:
	return accepted_order != null and can_start_order(accepted_order)


func start_cooking() -> bool:
	if not can_cook():
		return false

	var order_to_cook: Order = accepted_order
	accepted_order = null
	return start_order(order_to_cook)


func complete_cooking() -> bool:
	if accepted_order != null:
		var order_to_complete: Order = accepted_order
		accepted_order = null
		return _complete_order(order_to_complete)

	if current_order == null:
		return false

	_complete_current_order()
	return true


func deliver_completed_order(customer: Customer, leave_target_position: Vector2) -> bool:
	if customer == null or not has_completed_order():
		return false

	if not customer.receive_completed_order(completed_order, leave_target_position):
		return false

	completed_order = null
	return true


func _complete_current_order() -> void:
	var order_to_complete: Order = current_order
	_clear_current_order()
	_complete_order(order_to_complete)


func _complete_order(order: Order) -> bool:
	if order == null or not order.complete():
		return false

	completed_order = order
	cooking_completed.emit(completed_order)
	return true


func _apply_cooking_speed_multiplier() -> void:
	cooking_speed_multiplier = GameManager.cooking_speed_multiplier


func _on_upgrades_changed() -> void:
	_apply_cooking_speed_multiplier()
	_apply_grill_visual_feedback()


func _resolve_flame_visual() -> void:
	if flame_visual_path.is_empty():
		return

	var visual_node: Node = get_node_or_null(flame_visual_path)
	if visual_node is CanvasItem:
		_flame_visual = visual_node as CanvasItem
		_base_flame_modulate = _flame_visual.modulate
		if _flame_visual is Node2D:
			_base_flame_scale = (_flame_visual as Node2D).scale


func _apply_grill_visual_feedback() -> void:
	if _flame_visual == null:
		return

	var level_offset: int = max(GameManager.grill_level - GameManager.DEFAULT_GRILL_LEVEL, 0)
	var intensity: float = 1.0 + float(level_offset) * FLAME_INTENSITY_STEP
	_flame_visual.modulate = Color(
		min(_base_flame_modulate.r * intensity, 1.0),
		min(_base_flame_modulate.g * intensity, 1.0),
		_base_flame_modulate.b,
		_base_flame_modulate.a
	)

	if _flame_visual is Node2D:
		var scale_multiplier: float = 1.0 + float(level_offset) * FLAME_SCALE_STEP
		(_flame_visual as Node2D).scale = _base_flame_scale * scale_multiplier
