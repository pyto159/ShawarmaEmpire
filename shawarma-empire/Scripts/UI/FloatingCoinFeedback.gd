extends Node2D
class_name FloatingCoinFeedback

const DEFAULT_FLOAT_DISTANCE: float = 64.0
const DEFAULT_DURATION: float = 0.9
const DEFAULT_TEXT_PREFIX: String = "+"
const DEFAULT_TEXT_SUFFIX: String = " Coins"
const FINAL_SCALE: Vector2 = Vector2(1.15, 1.15)
const START_SCALE: Vector2 = Vector2(0.9, 0.9)

@export var float_distance: float = DEFAULT_FLOAT_DISTANCE
@export var duration: float = DEFAULT_DURATION
@export var text_prefix: String = DEFAULT_TEXT_PREFIX
@export var text_suffix: String = DEFAULT_TEXT_SUFFIX

@onready var label: Label = %CoinAmountLabel


func _ready() -> void:
	visible = false


func play(amount: int) -> void:
	if amount <= 0:
		queue_free()
		return

	label.text = text_prefix + str(amount) + text_suffix
	visible = true
	_start_animation()


func _start_animation() -> void:
	var start_position: Vector2 = position
	var end_position: Vector2 = start_position + Vector2.UP * float_distance
	modulate = Color.WHITE
	scale = START_SCALE

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position", end_position, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale", FINAL_SCALE, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
