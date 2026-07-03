extends Node

const DEFAULT_SOUND_VOLUME_DB: float = -8.0
const DEFAULT_DEBOUNCE_SECONDS: float = 0.08
const CUSTOMER_SOUND_DEBOUNCE_SECONDS: float = 0.16
const COIN_SOUND_DEBOUNCE_SECONDS: float = 0.10
const PLAYER_POOL_SIZE: int = 4
const MIN_VOLUME_DB: float = -80.0
const MAX_VOLUME_DB: float = 6.0
const MUTE_VOLUME_DB: float = -80.0
const AUDIO_PLAYER_NAME_PREFIX: String = "SfxPlayer"

var _audio_players: Array[AudioStreamPlayer] = []
var _next_player_index: int = 0
var _last_played_msec_by_sound: Dictionary = {}

@export_range(0.0, 1.0, 0.01) var master_volume: float = 1.0:
	set(value):
		master_volume = clampf(value, 0.0, 1.0)
		_update_player_volumes()
@export_range(0.0, 1.0, 0.01) var sfx_volume: float = 1.0:
	set(value):
		sfx_volume = clampf(value, 0.0, 1.0)
		_update_player_volumes()
@export_range(0.0, 0.5, 0.01) var default_debounce_seconds: float = DEFAULT_DEBOUNCE_SECONDS
@export var button_sound: AudioStream
@export var coin_sound: AudioStream
@export var cooking_start_sound: AudioStream
@export var cooking_complete_sound: AudioStream
@export var customer_arrive_sound: AudioStream
@export var customer_leave_sound: AudioStream
@export var queue_move_sound: AudioStream
@export var upgrade_sound: AudioStream
@export var error_sound: AudioStream


func _ready() -> void:
	_register_existing_audio_players()
	_ensure_audio_players()
	_update_player_volumes()


func play_button() -> void:
	_play_sound(button_sound, "button", default_debounce_seconds)


func play_coin() -> void:
	_play_sound(coin_sound, "coin", COIN_SOUND_DEBOUNCE_SECONDS)


func play_cooking_start() -> void:
	_play_sound(cooking_start_sound, "cooking_start", default_debounce_seconds)


func play_cooking_complete() -> void:
	_play_sound(cooking_complete_sound, "cooking_complete", default_debounce_seconds)


func play_customer_arrive() -> void:
	_play_sound(customer_arrive_sound, "customer_arrive", CUSTOMER_SOUND_DEBOUNCE_SECONDS)


func play_customer_leave() -> void:
	_play_sound(customer_leave_sound, "customer_leave", CUSTOMER_SOUND_DEBOUNCE_SECONDS)


func play_queue_move() -> void:
	_play_sound(queue_move_sound, "queue_move", default_debounce_seconds)


func play_upgrade() -> void:
	_play_sound(upgrade_sound, "upgrade", default_debounce_seconds)


func play_error() -> void:
	_play_sound(error_sound, "error", default_debounce_seconds)


func _play_sound(sound: AudioStream, sound_key: String, debounce_seconds: float) -> void:
	if sound == null or _is_debounced(sound_key, debounce_seconds):
		return

	var audio_player: AudioStreamPlayer = _get_next_audio_player()
	if audio_player == null:
		return

	audio_player.stream = sound
	audio_player.play()


func _is_debounced(sound_key: String, debounce_seconds: float) -> bool:
	var current_msec: int = Time.get_ticks_msec()
	var debounce_msec: int = int(maxf(debounce_seconds, 0.0) * 1000.0)
	var last_played_msec: int = int(_last_played_msec_by_sound.get(sound_key, current_msec - debounce_msec))
	if current_msec - last_played_msec < debounce_msec:
		return true

	_last_played_msec_by_sound[sound_key] = current_msec
	return false


func _get_next_audio_player() -> AudioStreamPlayer:
	_ensure_audio_players()
	if _audio_players.is_empty():
		return null

	_next_player_index %= _audio_players.size()
	var audio_player: AudioStreamPlayer = _audio_players[_next_player_index]
	_next_player_index = (_next_player_index + 1) % _audio_players.size()
	return audio_player


func _register_existing_audio_players() -> void:
	for child: Node in get_children():
		if child is AudioStreamPlayer:
			var audio_player: AudioStreamPlayer = child as AudioStreamPlayer
			if not _audio_players.has(audio_player):
				_audio_players.append(audio_player)


func _ensure_audio_players() -> void:
	while _audio_players.size() < PLAYER_POOL_SIZE:
		var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
		audio_player.name = AUDIO_PLAYER_NAME_PREFIX + str(_audio_players.size() + 1)
		add_child(audio_player)
		_audio_players.append(audio_player)


func _update_player_volumes() -> void:
	if _audio_players == null:
		return

	var combined_volume: float = clampf(master_volume * sfx_volume, 0.0, 1.0)
	var volume_db: float = MUTE_VOLUME_DB
	if combined_volume > 0.0:
		volume_db = clampf(linear_to_db(combined_volume) + DEFAULT_SOUND_VOLUME_DB, MIN_VOLUME_DB, MAX_VOLUME_DB)

	for audio_player: AudioStreamPlayer in _audio_players:
		if audio_player != null:
			audio_player.volume_db = volume_db
