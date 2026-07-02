extends Node2D
class_name CustomerEmotion

const HAPPY_EMOJIS: Array[String] = ["🙂", "😋", "🤩", "❤️", "👍"]
const WAITING_EMOJIS: Array[String] = ["🤔", "🙂", "😐", "😴", "💭"]
const ANGRY_EMOJIS: Array[String] = ["😠", "😤", "🙄"]

const FLOAT_DISTANCE: float = 28.0
const FADE_IN_SECONDS: float = 0.12
const DEFAULT_HOLD_SECONDS: float = 0.55
const HAPPY_HOLD_SECONDS: float = 1.0
const FADE_OUT_SECONDS: float = 0.28
const START_SCALE: Vector2 = Vector2(0.72, 0.72)
const BOUNCE_SCALE: Vector2 = Vector2(1.18, 1.18)
const END_SCALE: Vector2 = Vector2.ONE

@onready var emotion_label: Label = %EmotionLabel

var _customer: Customer
var _emotion_tween: Tween


func _ready() -> void:
	visible = false
	modulate.a = 0.0
	emotion_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_connect_parent_customer()


func show_happy() -> void:
	_play_emotion(_get_random_emotion(HAPPY_EMOJIS), HAPPY_HOLD_SECONDS)


func show_waiting() -> void:
	_play_emotion(_get_random_emotion(WAITING_EMOJIS), DEFAULT_HOLD_SECONDS)


func show_angry() -> void:
	_play_emotion(_get_random_emotion(ANGRY_EMOJIS), DEFAULT_HOLD_SECONDS)


func show_thinking() -> void:
	show_waiting()


func _connect_parent_customer() -> void:
	var parent_node: Node = get_parent()
	if not parent_node is Customer:
		return

	_customer = parent_node as Customer
	_customer.state_changed.connect(_on_customer_state_changed)
	_customer.order_created.connect(_on_customer_order_created)
	_customer.food_received.connect(_on_customer_food_received)


func _on_customer_state_changed(new_state: Customer.CustomerState) -> void:
	if new_state == Customer.CustomerState.WAITING:
		show_waiting()


func _on_customer_order_created(_order: Order) -> void:
	show_thinking()


func _on_customer_food_received(_order: Order) -> void:
	show_happy()


func _play_emotion(emoji: String, hold_seconds: float) -> void:
	_cancel_animation()
	emotion_label.text = emoji
	visible = true
	modulate.a = 0.0
	scale = START_SCALE
	position = Vector2.ZERO

	var end_position: Vector2 = Vector2.UP * FLOAT_DISTANCE
	_emotion_tween = create_tween()
	_emotion_tween.set_parallel(true)
	_emotion_tween.tween_property(self, "modulate:a", 1.0, FADE_IN_SECONDS)
	_emotion_tween.tween_property(self, "scale", BOUNCE_SCALE, FADE_IN_SECONDS).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_emotion_tween.tween_property(self, "position", end_position, FADE_IN_SECONDS + hold_seconds + FADE_OUT_SECONDS).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_emotion_tween.set_parallel(false)
	_emotion_tween.tween_property(self, "scale", END_SCALE, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_emotion_tween.tween_interval(hold_seconds)
	_emotion_tween.tween_property(self, "modulate:a", 0.0, FADE_OUT_SECONDS).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_emotion_tween.parallel().tween_property(self, "scale", START_SCALE, FADE_OUT_SECONDS).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_emotion_tween.tween_callback(_hide_emotion)


func _get_random_emotion(emotions: Array[String]) -> String:
	if emotions.is_empty():
		return ""

	return emotions[randi() % emotions.size()]


func _cancel_animation() -> void:
	if _emotion_tween == null:
		return

	_emotion_tween.kill()
	_emotion_tween = null


func _hide_emotion() -> void:
	visible = false
	_emotion_tween = null
