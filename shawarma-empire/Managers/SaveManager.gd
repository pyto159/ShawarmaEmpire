extends Node

const SAVE_PATH: String = "user://shawarma_empire_save.json"


func save_game() -> void:
	var save_data: Dictionary = GameManager.get_save_data()
	var save_file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file == null:
		push_error("Unable to open save file for writing: %s" % SAVE_PATH)
		return

	save_file.store_string(JSON.stringify(save_data))


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		GameManager.set_currency(GameManager.STARTING_COINS, GameManager.STARTING_GEMS)
		return

	var save_file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if save_file == null:
		push_error("Unable to open save file for reading: %s" % SAVE_PATH)
		return

	var json: JSON = JSON.new()
	var parse_error: Error = json.parse(save_file.get_as_text())
	if parse_error != OK:
		push_error("Unable to parse save file: %s" % SAVE_PATH)
		return

	var save_data: Variant = json.data
	if save_data is Dictionary:
		GameManager.apply_save_data(save_data)
