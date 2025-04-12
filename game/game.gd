extends Node2D

signal game_over

enum GameState { AIMING, FLYING, WAITING, WIN, LOSE }

var _state := GameState.WAITING


func _ready() -> void:
	$Environment/LoseLine/CollisionShape2D.shape.distance = -(
		784 + 30 + min($Balls._ball_radius, 44)
	)


func _on_lose_line_body_entered(_body: Node2D) -> void:
	if _state == GameState.LOSE:
		return
	_state = GameState.LOSE
	game_over.emit()
	$Balls.max_speed = 88 * 2
	$Balls.mode = $Balls.MoveMode.CONTINUOUS
	$Environment/LoseLine.set_deferred("monitoring", false)
