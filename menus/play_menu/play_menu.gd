extends Control


func _ready() -> void:
	$VBoxContainer/ContinuousToggleSwitch.button_pressed = GameMode.continuous


func _start_game(difficulty: GameMode.Difficulty) -> void:
	GameMode.difficulty = difficulty
	get_tree().change_scene_to_file("res://game/game_frame.tscn")


func _on_easy_button_pressed() -> void:
	_start_game(GameMode.Difficulty.EASY)


func _on_medium_button_pressed() -> void:
	_start_game(GameMode.Difficulty.MEDIUM)


func _on_hard_button_pressed() -> void:
	_start_game(GameMode.Difficulty.HARD)


func _on_custom_button_pressed() -> void:
	_start_game(GameMode.Difficulty.CUSTOM)


func _on_custom_edit_button_pressed() -> void:
	$Panel.show()


func _on_continuous_toggle_switch_toggled(toggled_on: bool) -> void:
	GameMode.continuous = toggled_on


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/title_screen.tscn")


func _on_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		_on_custom_difficulty_menu_close()


func _on_custom_difficulty_menu_close() -> void:
	$Panel.hide()
