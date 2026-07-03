extends Node

const DEFAULT_SOUND_VOLUME_DB: float = -8.0
const DEFAULT_DEBOUNCE_SECONDS: float = 0.08
const CUSTOMER_SOUND_DEBOUNCE_SECONDS: float = 0.16
const COIN_SOUND_DEBOUNCE_SECONDS: float = 0.10
const PLACEHOLDER_SAMPLE_RATE: int = 22050
const PLACEHOLDER_VOLUME: float = 0.18
const PLACEHOLDER_ATTACK_SECONDS: float = 0.01
const PLACEHOLDER_RELEASE_SECONDS: float = 0.04
const PLAYER_POOL_SIZE: int = 4
const MIN_VOLUME_DB: float = -80.0
const MAX_VOLUME_DB: float = 6.0
const MUTE_VOLUME_DB: float = -80.0
const AUDIO_PLAYER_NAME_PREFIX: String = "SfxPlayer"
const SOUND_BUTTON: String = "button"
const SOUND_COIN: String = "coin"
const SOUND_COOKING_START: String = "cooking_start"
const SOUND_COOKING_COMPLETE: String = "cooking_complete"
const SOUND_CUSTOMER_ARRIVE: String = "customer_arrive"
const SOUND_CUSTOMER_LEAVE: String = "customer_leave"
const SOUND_QUEUE_MOVE: String = "queue_move"
const SOUND_UPGRADE: String = "upgrade"
const SOUND_ERROR: String = "error"
const UI_SOUND_KEYS: Array[String] = [SOUND_BUTTON, SOUND_UPGRADE, SOUND_ERROR]

var _audio_players: Array[AudioStreamPlayer] = []
var _next_player_index: int = 0
var _last_played_msec_by_sound: Dictionary = {}
var _placeholder_sounds: Dictionary = {}

@export_range(0.0, 1.0, 0.01) var master_volume: float = 1.0:
	set(value):
		master_volume = clampf(value, 0.0, 1.0)
		_update_player_volumes()
@export_range(0.0, 1.0, 0.01) var ui_volume: float = 1.0:
	set(value):
		ui_volume = clampf(value, 0.0, 1.0)
		_update_player_volumes()
@export_range(0.0, 1.0, 0.01) var gameplay_volume: float = 1.0:
	set(value):
		gameplay_volume = clampf(value, 0.0, 1.0)
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
	_create_placeholder_sounds()
	_register_existing_audio_players()
	_ensure_audio_players()
	_update_player_volumes()


func play_button() -> void:
	_play_sound(button_sound, SOUND_BUTTON, default_debounce_seconds)


func play_coin() -> void:
	_play_sound(coin_sound, SOUND_COIN, COIN_SOUND_DEBOUNCE_SECONDS)


func play_cooking_start() -> void:
	_play_sound(cooking_start_sound, SOUND_COOKING_START, default_debounce_seconds)


func play_cooking_complete() -> void:
	_play_sound(cooking_complete_sound, SOUND_COOKING_COMPLETE, default_debounce_seconds)


func play_customer_arrive() -> void:
	_play_sound(customer_arrive_sound, SOUND_CUSTOMER_ARRIVE, CUSTOMER_SOUND_DEBOUNCE_SECONDS)


func play_customer_leave() -> void:
	_play_sound(customer_leave_sound, SOUND_CUSTOMER_LEAVE, CUSTOMER_SOUND_DEBOUNCE_SECONDS)


func play_queue_move() -> void:
	_play_sound(queue_move_sound, SOUND_QUEUE_MOVE, default_debounce_seconds)


func play_upgrade() -> void:
	_play_sound(upgrade_sound, SOUND_UPGRADE, default_debounce_seconds)


func play_error() -> void:
	_play_sound(error_sound, SOUND_ERROR, default_debounce_seconds)


func _play_sound(sound: AudioStream, sound_key: String, debounce_seconds: float) -> void:
	if _is_debounced(sound_key, debounce_seconds):
		return

	var playable_sound: AudioStream = _get_playable_sound(sound, sound_key)
	if playable_sound == null:
		return

	var audio_player: AudioStreamPlayer = _get_next_audio_player()
	if audio_player == null:
		return

	audio_player.volume_db = _get_volume_db(sound_key)
	audio_player.stream = playable_sound
	audio_player.play()


func _get_playable_sound(sound: AudioStream, sound_key: String) -> AudioStream:
	if sound != null:
		return sound

	return _placeholder_sounds.get(sound_key, null)


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

	var combined_volume: float = clampf(master_volume * maxf(ui_volume, gameplay_volume), 0.0, 1.0)
	var volume_db: float = MUTE_VOLUME_DB
	if combined_volume > 0.0:
		volume_db = clampf(linear_to_db(combined_volume) + DEFAULT_SOUND_VOLUME_DB, MIN_VOLUME_DB, MAX_VOLUME_DB)

	for audio_player: AudioStreamPlayer in _audio_players:
		if audio_player != null:
			audio_player.volume_db = volume_db


func _get_volume_db(sound_key: String) -> float:
	var category_volume: float = gameplay_volume
	if UI_SOUND_KEYS.has(sound_key):
		category_volume = ui_volume

	var combined_volume: float = clampf(master_volume * category_volume, 0.0, 1.0)
	if combined_volume <= 0.0:
		return MUTE_VOLUME_DB

	return clampf(linear_to_db(combined_volume) + DEFAULT_SOUND_VOLUME_DB, MIN_VOLUME_DB, MAX_VOLUME_DB)


func _create_placeholder_sounds() -> void:
	_placeholder_sounds[SOUND_BUTTON] = _create_tone(620.0, 0.055)
	_placeholder_sounds[SOUND_COIN] = _create_tone_sequence([880.0, 1320.0], 0.045)
	_placeholder_sounds[SOUND_COOKING_START] = _create_tone(260.0, 0.12)
	_placeholder_sounds[SOUND_COOKING_COMPLETE] = _create_tone_sequence([523.25, 783.99], 0.07)
	_placeholder_sounds[SOUND_CUSTOMER_ARRIVE] = _create_tone(440.0, 0.07)
	_placeholder_sounds[SOUND_CUSTOMER_LEAVE] = _create_tone(330.0, 0.07)
	_placeholder_sounds[SOUND_QUEUE_MOVE] = _create_tone(520.0, 0.04)
	_placeholder_sounds[SOUND_UPGRADE] = _create_tone_sequence([659.25, 880.0, 1174.66], 0.06)
	_placeholder_sounds[SOUND_ERROR] = _create_tone(180.0, 0.09)


func _create_tone_sequence(frequencies: Array[float], note_seconds: float) -> AudioStreamWAV:
	var data: PackedByteArray = PackedByteArray()
	for frequency: float in frequencies:
		data.append_array(_create_tone_data(frequency, note_seconds))

	return _create_wav_stream(data)


func _create_tone(frequency: float, duration_seconds: float) -> AudioStreamWAV:
	return _create_wav_stream(_create_tone_data(frequency, duration_seconds))


func _create_tone_data(frequency: float, duration_seconds: float) -> PackedByteArray:
	var data: PackedByteArray = PackedByteArray()
	var sample_count: int = int(duration_seconds * PLACEHOLDER_SAMPLE_RATE)
	for sample_index: int in range(sample_count):
		var time: float = float(sample_index) / float(PLACEHOLDER_SAMPLE_RATE)
		var envelope: float = _get_envelope(sample_index, sample_count)
		var sample: float = sin(TAU * frequency * time) * PLACEHOLDER_VOLUME * envelope
		var sample_value: int = int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.append(sample_value & 0xff)
		data.append((sample_value >> 8) & 0xff)

	return data


func _get_envelope(sample_index: int, sample_count: int) -> float:
	var attack_samples: int = int(PLACEHOLDER_ATTACK_SECONDS * PLACEHOLDER_SAMPLE_RATE)
	var release_samples: int = int(PLACEHOLDER_RELEASE_SECONDS * PLACEHOLDER_SAMPLE_RATE)
	if attack_samples > 0 and sample_index < attack_samples:
		return float(sample_index) / float(attack_samples)

	var samples_until_end: int = sample_count - sample_index
	if release_samples > 0 and samples_until_end < release_samples:
		return float(samples_until_end) / float(release_samples)

	return 1.0


func _create_wav_stream(data: PackedByteArray) -> AudioStreamWAV:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = PLACEHOLDER_SAMPLE_RATE
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	stream.data = data
	return stream
