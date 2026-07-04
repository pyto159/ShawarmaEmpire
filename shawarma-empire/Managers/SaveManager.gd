extends Node

const SAVE_PATH: String = "user://shawarma_empire_save.json"

var _save_queued: bool = false


func save_game() -> void:
	var save_data: Dictionary = GameManager.get_save_data()
	var save_file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file == null:
		push_error("Unable to open save file for writing: %s" % SAVE_PATH)
		return

	save_file.store_string(JSON.stringify(save_data))


func queue_save_game() -> void:
	if _save_queued:
		return

	_save_queued = true
	call_deferred("_flush_queued_save")


func load_game() -> void:
	if not has_save():
		initialize_new_game()
		return

	var save_file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if save_file == null:
		push_error("Unable to open save file for reading: %s" % SAVE_PATH)
		initialize_new_game()
		return

	var json: JSON = JSON.new()
	var parse_error: Error = json.parse(save_file.get_as_text())
	if parse_error != OK:
		push_error("Unable to parse save file: %s" % SAVE_PATH)
		initialize_new_game()
		return

	var save_data: Variant = json.data
	if save_data is Dictionary:
		GameManager.apply_save_data(save_data)
	else:
		push_error("Save file did not contain a dictionary: %s" % SAVE_PATH)
		initialize_new_game()


func delete_save() -> void:
	_save_queued = false
	if not has_save():
		return

	var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	if error != OK:
		push_error("Unable to delete save file: %s" % SAVE_PATH)


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func initialize_new_game() -> void:
	GameManager.initialize_new_game()


func _flush_queued_save() -> void:
	_save_queued = false
	save_game()
