extends PanelContainer
@onready var game: Game = %Game
@onready var saved_label: Label = $VBoxContainer/PanelContainer2/SavedLabel
@onready var score_label: Label = $VBoxContainer/PanelContainer2/ScoreLabel
@onready var rows_label: Label = $VBoxContainer/PanelContainer2/RowsLabel
@onready var strike_bar: StrikeProgress = $VBoxContainer/HBoxContainer/StrikeBar


func _process(_delta: float) -> void:
	saved_label.text = "Saved: " + str(game.game_status.saved).pad_zeros(4)
	score_label.text = "Score: " + str(game.game_status.score).pad_zeros(4)
	rows_label.text = "Rows: " + str(game.game_status.rows).pad_zeros(3)
	strike_bar.value = game.game_status.bouncer
	strike_bar.strikes = game.game_status.strikes


func _on_pause_button_pressed() -> void:
	get_tree().paused = true
	$Panel.show()


func _on_pause_menu_resume() -> void:
	$Panel.hide()
	get_tree().paused = false
