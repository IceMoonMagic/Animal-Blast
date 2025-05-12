extends Control

signal close


func _ready() -> void:
	$VBoxContainer/GridContainer/BallsPerRowSlider.value = (
		GameMode.custom_difficulty.row_size
	)
	$VBoxContainer/GridContainer/PaletteSizeSlider.value = (
		GameMode.custom_difficulty.palette_size
	)
	$VBoxContainer/GridContainer/ConstinousSpeedSpinBox.value = (
		GameMode.custom_difficulty.continuous_speed
	)
	$VBoxContainer/GridContainer/StrikesSpinBox.value = (
		GameMode.custom_difficulty.allowed_strikes
	)


func _on_balls_per_row_slider_value_changed(value: float) -> void:
	GameMode.custom_difficulty.row_size = roundi(value)


func _on_palette_size_slider_value_changed(value: float) -> void:
	GameMode.custom_difficulty.palette_size = roundi(value)


func _on_constinous_speed_spin_box_value_changed(value: float) -> void:
	GameMode.custom_difficulty.continuous_speed = value


func _on_strikes_spin_box_value_changed(value: float) -> void:
	GameMode.custom_difficulty.allowed_strikes = roundi(value)


func _on_done_button_pressed() -> void:
	close.emit()
	#get_tree().change_scene_to_file("res://menus/play_menu/play_menu.tscn")
