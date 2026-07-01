extends Control


func _ready() -> void:
	SaveManager.load_game()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		SaveManager.save_game()
