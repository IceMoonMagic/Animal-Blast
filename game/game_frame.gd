extends PanelContainer


func _on_pause_button_pressed() -> void:
	get_tree().paused = true
	$Panel.show()


func _on_pause_menu_resume() -> void:
	$Panel.hide()
	get_tree().paused = false
