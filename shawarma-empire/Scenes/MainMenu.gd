extends Control

const GAME_SCENE_PATH: String = "res://Scenes/Main.tscn"
const NEW_GAME_CONFIRMATION_TEXT: String = "Start a new game?\nYour current progress will be permanently deleted."
const PANEL_CORNER_RADIUS: int = 28
const BUTTON_CORNER_RADIUS: int = 20

@onready var continue_button: Button = %ContinueButton
@onready var new_game_button: Button = %NewGameButton
@onready var confirmation_dialog: ConfirmationDialog = %NewGameConfirmationDialog


func _ready() -> void:
	_apply_theme()
	continue_button.visible = SaveManager.has_save()
	continue_button.pressed.connect(_on_continue_pressed)
	new_game_button.pressed.connect(_on_new_game_pressed)
	confirmation_dialog.confirmed.connect(_on_new_game_confirmed)


func _apply_theme() -> void:
	var panel: PanelContainer = %MenuPanel
	panel.add_theme_stylebox_override("panel", _create_panel_style(Color(1.0, 0.91, 0.76, 0.96)))
	for button: Button in [continue_button, new_game_button]:
		button.add_theme_font_size_override("font_size", 26)
		button.add_theme_stylebox_override("normal", _create_button_style(Color(0.24, 0.63, 0.34, 1.0)))
		button.add_theme_stylebox_override("hover", _create_button_style(Color(0.30, 0.72, 0.40, 1.0)))
		button.add_theme_stylebox_override("pressed", _create_button_style(Color(0.18, 0.50, 0.27, 1.0)))


func _create_panel_style(color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = PANEL_CORNER_RADIUS
	style.corner_radius_top_right = PANEL_CORNER_RADIUS
	style.corner_radius_bottom_left = PANEL_CORNER_RADIUS
	style.corner_radius_bottom_right = PANEL_CORNER_RADIUS
	style.shadow_color = Color(0.25, 0.12, 0.04, 0.22)
	style.shadow_size = 12
	style.shadow_offset = Vector2(0, 6)
	return style


func _create_button_style(color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = BUTTON_CORNER_RADIUS
	style.corner_radius_top_right = BUTTON_CORNER_RADIUS
	style.corner_radius_bottom_left = BUTTON_CORNER_RADIUS
	style.corner_radius_bottom_right = BUTTON_CORNER_RADIUS
	return style


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
