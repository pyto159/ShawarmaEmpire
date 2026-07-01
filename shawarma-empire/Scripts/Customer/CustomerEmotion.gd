extends Node2D
class_name CustomerEmotion

const HAPPY_EMOJI: String = "🙂"
const WAITING_EMOJI: String = "🤔"
const ANGRY_EMOJI: String = "😠"
const THINKING_EMOJI: String = "💭"

const FLOAT_DISTANCE: float = 18.0
const FADE_IN_SECONDS: float = 0.12
const DEFAULT_HOLD_SECONDS: float = 0.55
const HAPPY_HOLD_SECONDS: float = 1.0
const FADE_OUT_SECONDS: float = 0.28
const START_SCALE: Vector2 = Vector2(0.85, 0.85)
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
	_play_emotion(HAPPY_EMOJI, HAPPY_HOLD_SECONDS)


func show_waiting() -> void:
	_play_emotion(WAITING_EMOJI, DEFAULT_HOLD_SECONDS)


func show_angry() -> void:
	_play_emotion(ANGRY_EMOJI, DEFAULT_HOLD_SECONDS)


func show_thinking() -> void:
	_play_emotion(THINKING_EMOJI, DEFAULT_HOLD_SECONDS)


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
	_emotion_tween.tween_property(self, "scale", END_SCALE, FADE_IN_SECONDS).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_emotion_tween.tween_property(self, "position", end_position, FADE_IN_SECONDS + hold_seconds + FADE_OUT_SECONDS).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_emotion_tween.set_parallel(false)
	_emotion_tween.tween_interval(hold_seconds)
	_emotion_tween.tween_property(self, "modulate:a", 0.0, FADE_OUT_SECONDS).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_emotion_tween.tween_callback(_hide_emotion)


func _cancel_animation() -> void:
	if _emotion_tween == null:
		return

	_emotion_tween.kill()
	_emotion_tween = null


func _hide_emotion() -> void:
	visible = false
	_emotion_tween = null
