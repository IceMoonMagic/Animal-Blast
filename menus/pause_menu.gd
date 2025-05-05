extends Control

signal resume


func _on_resume_button_pressed() -> void:
	resume.emit()


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://game/game_frame.tscn")


func _on_options_button_pressed() -> void:
	#get_tree().change_scene_to_file("res://menus/")
	pass  # Replace with function body.


func _on_to_title_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menus/title_screen.tscn")
