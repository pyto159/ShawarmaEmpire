extends Node2D
class_name FloatingCoinLabel

const FLOAT_DISTANCE: float = 50.0
const FADE_DURATION: float = 0.8
const SCALE_DURATION: float = 0.15
const START_SCALE: Vector2 = Vector2(0.8, 0.8)
const END_SCALE: Vector2 = Vector2.ONE
const TEXT_PREFIX: String = "+"

@onready var amount_label: RichTextLabel = %AmountLabel


func _ready() -> void:
	visible = false
	amount_label.mouse_filter = Control.MOUSE_FILTER_IGNORE


func play(amount: int) -> void:
	if amount <= 0:
		queue_free()
		return

	amount_label.text = "[center][b]" + TEXT_PREFIX + str(amount) + "[/b][/center]"
	visible = true
	_start_animation()


func _start_animation() -> void:
	var start_position: Vector2 = position
	var end_position: Vector2 = start_position + Vector2.UP * FLOAT_DISTANCE
	modulate = Color.WHITE
	scale = START_SCALE

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position", end_position, FADE_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, FADE_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale", END_SCALE, SCALE_DURATION).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
