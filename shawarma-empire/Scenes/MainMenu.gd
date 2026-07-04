extends Control

const GAME_SCENE_PATH: String = "res://Scenes/Main.tscn"
const NEW_GAME_CONFIRMATION_TEXT: String = "Start a new game?\nYour current progress will be permanently deleted."
@onready var continue_button: Button = %ContinueButton
@onready var new_game_button: Button = %NewGameButton
@onready var confirmation_dialog: ConfirmationDialog = %NewGameConfirmationDialog


func _ready() -> void:
	continue_button.visible = SaveManager.has_save()
	continue_button.pressed.connect(_on_continue_pressed)
	new_game_button.pressed.connect(_on_new_game_pressed)
	confirmation_dialog.confirmed.connect(_on_new_game_confirmed)


func _on_continue_pressed() -> void:
	AudioManager.play_button()
	SaveManager.load_game()
	SceneManager.change_scene(GAME_SCENE_PATH)


func _on_new_game_pressed() -> void:
	AudioManager.play_button()
	if SaveManager.has_save():
		confirmation_dialog.dialog_text = NEW_GAME_CONFIRMATION_TEXT
		confirmation_dialog.popup_centered()
		return

	_start_new_game()


func _on_new_game_confirmed() -> void:
	_start_new_game()


func _start_new_game() -> void:
	SaveManager.delete_save()
	SaveManager.initialize_new_game()
	SaveManager.save_game()
	SceneManager.change_scene(GAME_SCENE_PATH)
