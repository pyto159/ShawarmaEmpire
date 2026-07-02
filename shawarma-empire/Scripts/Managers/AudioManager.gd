extends Node

const DEFAULT_SOUND_VOLUME_DB: float = -8.0
const DEFAULT_DEBOUNCE_SECONDS: float = 0.08
const CUSTOMER_SOUND_DEBOUNCE_SECONDS: float = 0.16
const COIN_SOUND_DEBOUNCE_SECONDS: float = 0.10
const SAMPLE_RATE: int = 22050
const PLAYER_POOL_SIZE: int = 4
const MIN_VOLUME_DB: float = -80.0
const MAX_VOLUME_DB: float = 6.0
const MUTE_VOLUME_DB: float = -80.0

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

var _audio_players: Array[AudioStreamPlayer] = []
var _next_player_index: int = 0
var _last_played_msec_by_sound: Dictionary = {}


func _ready() -> void:
	_ensure_audio_players()
	_assign_default_sounds()
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
	audio_player.stream = sound
	audio_player.play()


func _is_debounced(sound_key: String, debounce_seconds: float) -> bool:
	var current_msec: int = Time.get_ticks_msec()
	var debounce_msec: int = int(maxf(debounce_seconds, 0.0) * 1000.0)
	var last_played_msec: int = int(_last_played_msec_by_sound.get(sound_key, -debounce_msec))
	if current_msec - last_played_msec < debounce_msec:
		return true

	_last_played_msec_by_sound[sound_key] = current_msec
	return false


func _get_next_audio_player() -> AudioStreamPlayer:
	_ensure_audio_players()
	var audio_player: AudioStreamPlayer = _audio_players[_next_player_index]
	_next_player_index = (_next_player_index + 1) % _audio_players.size()
	return audio_player


func _ensure_audio_players() -> void:
	while _audio_players.size() < PLAYER_POOL_SIZE:
		var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
		add_child(audio_player)
		_audio_players.append(audio_player)


func _update_player_volumes() -> void:
	var combined_volume: float = clampf(master_volume * sfx_volume, 0.0, 1.0)
	var volume_db: float = MUTE_VOLUME_DB
	if combined_volume > 0.0:
		volume_db = clampf(linear_to_db(combined_volume) + DEFAULT_SOUND_VOLUME_DB, MIN_VOLUME_DB, MAX_VOLUME_DB)

	for audio_player: AudioStreamPlayer in _audio_players:
		audio_player.volume_db = volume_db


func _assign_default_sounds() -> void:
	if button_sound == null:
		button_sound = _create_tone_sound(580.0, 700.0, 0.06, 0.35)
	if coin_sound == null:
		coin_sound = _create_tone_sound(1200.0, 1680.0, 0.12, 0.45)
	if cooking_start_sound == null:
		cooking_start_sound = _create_tone_sound(300.0, 460.0, 0.14, 0.30)
	if cooking_complete_sound == null:
		cooking_complete_sound = _create_tone_sound(820.0, 1320.0, 0.16, 0.42)
	if customer_arrive_sound == null:
		customer_arrive_sound = _create_tone_sound(430.0, 560.0, 0.09, 0.28)
	if customer_leave_sound == null:
		customer_leave_sound = _create_tone_sound(520.0, 330.0, 0.10, 0.28)
	if queue_move_sound == null:
		queue_move_sound = _create_tone_sound(650.0, 760.0, 0.05, 0.24)
	if upgrade_sound == null:
		upgrade_sound = _create_tone_sound(700.0, 1500.0, 0.20, 0.42)
	if error_sound == null:
		error_sound = _create_tone_sound(180.0, 120.0, 0.12, 0.34)


func _create_tone_sound(start_frequency: float, end_frequency: float, duration_seconds: float, amplitude: float) -> AudioStreamWAV:
	var sample_count: int = int(float(SAMPLE_RATE) * duration_seconds)
	var data: PackedByteArray = PackedByteArray()
	data.resize(sample_count * 2)
	var write_index: int = 0
	for sample_index: int in range(sample_count):
		var progress: float = float(sample_index) / float(maxi(sample_count - 1, 1))
		var frequency: float = lerpf(start_frequency, end_frequency, progress)
		var envelope: float = sin(progress * PI)
		var wave: float = sin(TAU * frequency * float(sample_index) / float(SAMPLE_RATE))
		var sample_value: int = int(wave * envelope * amplitude * 32767.0)
		data[write_index] = sample_value & 0xff
		data[write_index + 1] = (sample_value >> 8) & 0xff
		write_index += 2

	var audio_stream: AudioStreamWAV = AudioStreamWAV.new()
	audio_stream.format = AudioStreamWAV.FORMAT_16_BITS
	audio_stream.mix_rate = SAMPLE_RATE
	audio_stream.stereo = false
	audio_stream.data = data
	return audio_stream
