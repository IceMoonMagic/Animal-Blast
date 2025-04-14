extends Node2D

signal warning_triggered
signal warning_cleared
signal game_over

enum GameState { AIMING, FLYING, WAITING, WIN, LOSE }

var _in_warning := false
var _state := GameState.WAITING


func _ready() -> void:
	const TILE_SIZE := 88
	const FENCE_COMPENSATION := 30
	var radius_compisation := minf($Balls._ball_radius, 44)
	$Environment/WarningLine/CollisionShape2D.shape.distance = -(
		TILE_SIZE * 8 + radius_compisation
	)
	$Environment/LoseLine/CollisionShape2D.shape.distance = -(
		TILE_SIZE * 9 + FENCE_COMPENSATION + radius_compisation
	)
	$Environment/LoseLine/Line2D.position = Vector2(
		0, TILE_SIZE * 9 + FENCE_COMPENSATION + radius_compisation
	)


func _on_warning_line_body_interacted(_body: Node2D) -> void:
	if len($Environment/WarningLine.get_overlapping_bodies()) > 0:
		if not _in_warning:
			_in_warning = true
			warning_triggered.emit()
	elif _in_warning:
		_in_warning = false
		warning_cleared.emit()


func _on_lose_line_body_entered(_body: Node2D) -> void:
	if _state == GameState.LOSE:
		return
	_state = GameState.LOSE
	game_over.emit()
	$Balls.max_speed = 88 * 2
	$Balls.mode = $Balls.MoveMode.CONTINUOUS
	$Environment/LoseLine.set_deferred("monitoring", false)
