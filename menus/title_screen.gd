extends Control


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/play_menu/play_menu.tscn")


func _on_palettes_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/options/palette_menu.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_licenses_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/licenses/licenses.tscn")
