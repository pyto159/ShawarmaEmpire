extends Node

const COIN_POPUP_SCENE: PackedScene = preload("res://Scenes/UI/FloatingCoinLabel.tscn")
const CUSTOMER_EMOTION_SCENE: PackedScene = preload("res://Scenes/UI/CustomerEmotion.tscn")

const COIN_POPUP_OFFSET: Vector2 = Vector2(0.0, -48.0)
const DEFAULT_EFFECT_Z_INDEX: int = 1000
const DEFAULT_PARTICLE_AMOUNT: int = 12
const DEFAULT_PARTICLE_LIFETIME: float = 0.55
const DEFAULT_PARTICLE_CLEANUP_PADDING: float = 0.2
const DEFAULT_PARTICLE_GRAVITY: Vector2 = Vector2(0.0, 260.0)
const DEFAULT_PARTICLE_SPEED_MIN: float = 80.0
const DEFAULT_PARTICLE_SPEED_MAX: float = 160.0
const CLICK_RING_RADIUS: float = 26.0
const CLICK_RING_WIDTH: float = 3.0
const CLICK_RING_DURATION: float = 0.22
const CLICK_RING_POINTS: int = 32
const SMOKE_PARTICLE_AMOUNT: int = 10
const SMOKE_PARTICLE_LIFETIME: float = 0.85
const CONFETTI_PARTICLE_AMOUNT: int = 28
const CONFETTI_PARTICLE_LIFETIME: float = 0.9

const COIN_COLOR: Color = Color(1.0, 0.84, 0.18, 1.0)
const CLICK_COLOR: Color = Color(1.0, 0.93, 0.55, 1.0)
const SMOKE_COLOR: Color = Color(0.72, 0.68, 0.62, 0.7)
const CONFETTI_COLOR: Color = Color(1.0, 0.32, 0.28, 1.0)

var _effects_layer: Node2D


func _ready() -> void:
	_effects_layer = Node2D.new()
	_effects_layer.name = "EffectsLayer"
	_effects_layer.z_index = DEFAULT_EFFECT_Z_INDEX
	add_child(_effects_layer)


func spawn_coin_popup(world_position: Vector2, amount: int, parent: Node = null) -> FloatingCoinLabel:
	if amount <= 0:
		return null

	var popup: FloatingCoinLabel = COIN_POPUP_SCENE.instantiate() as FloatingCoinLabel
	_get_parent(parent).add_child(popup)
	popup.global_position = world_position + COIN_POPUP_OFFSET
	popup.play(amount)
	return popup


func spawn_customer_emotion(world_position: Vector2, emotion: String, parent: Node = null) -> Label:
	if emotion.is_empty():
		return null

	var emotion_label: Label = Label.new()
	emotion_label.text = emotion
	emotion_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emotion_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	emotion_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	emotion_label.global_position = world_position
	_get_parent(parent).add_child(emotion_label)
	_play_float_and_fade(emotion_label)
	return emotion_label


func spawn_particles(world_position: Vector2, color: Color = COIN_COLOR, parent: Node = null) -> CPUParticles2D:
	return _spawn_particle_burst(world_position, DEFAULT_PARTICLE_AMOUNT, DEFAULT_PARTICLE_LIFETIME, color, DEFAULT_PARTICLE_GRAVITY, parent)


func spawn_click_effect(world_position: Vector2, parent: Node = null) -> Line2D:
	var ring: Line2D = Line2D.new()
	ring.closed = true
	ring.width = CLICK_RING_WIDTH
	ring.default_color = CLICK_COLOR
	ring.points = _build_circle_points(CLICK_RING_RADIUS)
	_get_parent(parent).add_child(ring)
	ring.global_position = world_position

	var tween: Tween = ring.create_tween()
	tween.set_parallel(true)
	tween.tween_property(ring, "scale", Vector2(1.35, 1.35), CLICK_RING_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(ring, "modulate:a", 0.0, CLICK_RING_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.set_parallel(false)
	tween.tween_callback(ring.queue_free)
	return ring


func spawn_smoke(world_position: Vector2, parent: Node = null) -> CPUParticles2D:
	return _spawn_particle_burst(world_position, SMOKE_PARTICLE_AMOUNT, SMOKE_PARTICLE_LIFETIME, SMOKE_COLOR, Vector2.UP * 80.0, parent)


func spawn_confetti(world_position: Vector2, parent: Node = null) -> CPUParticles2D:
	return _spawn_particle_burst(world_position, CONFETTI_PARTICLE_AMOUNT, CONFETTI_PARTICLE_LIFETIME, CONFETTI_COLOR, DEFAULT_PARTICLE_GRAVITY, parent)


func _get_parent(parent: Node) -> Node:
	if parent != null:
		return parent

	return _effects_layer


func _spawn_particle_burst(world_position: Vector2, amount: int, lifetime: float, color: Color, gravity: Vector2, parent: Node) -> CPUParticles2D:
	var particles: CPUParticles2D = CPUParticles2D.new()
	particles.amount = amount
	particles.lifetime = lifetime
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.emitting = false
	particles.direction = Vector2.UP
	particles.spread = 180.0
	particles.gravity = gravity
	particles.initial_velocity_min = DEFAULT_PARTICLE_SPEED_MIN
	particles.initial_velocity_max = DEFAULT_PARTICLE_SPEED_MAX
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 5.0
	particles.color = color
	_get_parent(parent).add_child(particles)
	particles.global_position = world_position
	particles.emitting = true
	_schedule_free(particles, lifetime + DEFAULT_PARTICLE_CLEANUP_PADDING)
	return particles


func _schedule_free(node: Node, delay_seconds: float) -> void:
	var timer: SceneTreeTimer = get_tree().create_timer(delay_seconds)
	timer.timeout.connect(node.queue_free)


func _play_float_and_fade(node: CanvasItem) -> void:
	var tween: Tween = node.create_tween()
	tween.set_parallel(true)
	tween.tween_property(node, "position", node.position + Vector2.UP * 24.0, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate:a", 0.0, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.set_parallel(false)
	tween.tween_callback(node.queue_free)


func _build_circle_points(radius: float) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for index: int in range(CLICK_RING_POINTS):
		var radians: float = TAU * float(index) / float(CLICK_RING_POINTS)
		points.append(Vector2(cos(radians), sin(radians)) * radius)

	return points
