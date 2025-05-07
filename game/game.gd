class_name Game
extends Node2D

signal warning_triggered
signal warning_cleared
signal game_over

enum GameState { AIMING, FLYING, WAITING, WIN, LOSE }

var game_status := GameStatus.new()
var _in_warning := false
var _state := GameState.WAITING
var _fly_speed := 360.0
var _flying_ball: Ball
@onready var balls: BallGrid = $Balls
@onready var launcher: BallLanucher = $BallLauncher


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
	if not GameMode.continous:
		for _i: int in range(5):
			balls.push_row()
			launcher.can_fire = false
			await balls.intermittent_move_done
			launcher.can_fire = true


func _physics_process(delta: float) -> void:
	if _flying_ball == null:
		return
	var remaining_movement: float = _fly_speed * delta
	while _state == GameState.FLYING:
		var collision: KinematicCollision2D = _flying_ball.move_and_collide(
			_flying_ball.constant_linear_velocity * remaining_movement
		)
		if collision == null or collision.get_collider() == null:
			break
		elif collision.get_collider() != get_node("Environment/Edges"):
			var pop_queue_length := len(balls.pop_queue)
			$Balls.place_ball(
				_flying_ball, $Balls.coords_to_index(_flying_ball.position)
			)
			_flying_ball = null
			_state = GameState.WAITING
			launcher.can_fire = true
			var popped: int = maxi(len(balls.pop_queue) - pop_queue_length, 0)
			game_status.saved += popped
			if popped == 0 and not GameMode.continous:
				game_status.strikes += 1
				if (
					game_status.strikes
					>= GameMode.difficulty_settings.allowed_strikes
				):
					balls.push_row()
					launcher.can_fire = false
					await balls.intermittent_move_done
					launcher.can_fire = true
					game_status.strikes = 0
			break
		else:
			remaining_movement = collision.get_remainder().length()
			_flying_ball.constant_linear_velocity = (
				_flying_ball
				. constant_linear_velocity
				. bounce(collision.get_normal())
			)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		launcher._current_angle_rad = launcher.position.angle_to_point(
			event.position
		)
		launcher.fire()


func _on_ball_launcher_ball_fired(ball: Ball) -> void:
	ball.reparent(self)
	_flying_ball = ball
	launcher.can_fire = false
	_state = GameState.FLYING


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
	$BallLauncher.can_fire = false
	game_over.emit()
	$Balls.max_speed = 88 * 2
	$Balls.mode = $Balls.MoveMode.CONTINUOUS
	$Environment/LoseLine.set_deferred("monitoring", false)


class GameStatus:
	var rows: int = 0
	var saved: int = 0:
		set(val):
			saved = val
			score += floori((val * (val + 1)) / 2.0)

	var score: int = 0

	var strikes: int = 0  # Progress on intermittent
	var bouncer: float = 0.0  # Progress on continous
