extends Node

@export var button_sound: AudioStream
@export var coin_sound: AudioStream
@export var cooking_start_sound: AudioStream
@export var cooking_complete_sound: AudioStream
@export var customer_arrive_sound: AudioStream
@export var customer_leave_sound: AudioStream
@export var queue_move_sound: AudioStream
@export var error_sound: AudioStream

var _audio_player: AudioStreamPlayer


func _ready() -> void:
	_ensure_audio_player()


func play_button() -> void:
	_play_sound(button_sound)


func play_coin() -> void:
	_play_sound(coin_sound)


func play_cooking_start() -> void:
	_play_sound(cooking_start_sound)


func play_cooking_complete() -> void:
	_play_sound(cooking_complete_sound)


func play_customer_arrive() -> void:
	_play_sound(customer_arrive_sound)


func play_customer_leave() -> void:
	_play_sound(customer_leave_sound)


func play_queue_move() -> void:
	_play_sound(queue_move_sound)


func play_error() -> void:
	_play_sound(error_sound)


func _play_sound(sound: AudioStream) -> void:
	if sound == null:
		return

	_ensure_audio_player()
	_audio_player.stream = sound
	_audio_player.play()


func _ensure_audio_player() -> void:
	if _audio_player != null:
		return

	_audio_player = AudioStreamPlayer.new()
	add_child(_audio_player)
