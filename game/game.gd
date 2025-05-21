class_name Game
extends Node2D

signal warning_triggered
signal warning_cleared
signal game_over

enum GameState { WAITING, FLYING, POPPING, LOSE }

var game_status := GameStatus.new()
var _in_warning := false
var _state := GameState.WAITING:
	set(state):
		if _state == state:
			return
		_state = state

		launcher.can_fire = state == GameState.WAITING
var _fly_speed := 360.0
var _flying_ball: Ball
@onready var balls: BallGrid = $Balls
@onready var launcher: BallLanucher = $BallLauncher


func _ready() -> void:
	const TILE_SIZE := 88
	const FENCE_COMPENSATION := 30
	var radius_compensation := minf(balls._ball_radius, 44)
	$Environment/WarningLine/CollisionShape2D.shape.distance = -(
		TILE_SIZE * 8 + radius_compensation
	)
	$Environment/LoseLine/CollisionShape2D.shape.distance = -(
		TILE_SIZE * 9 + FENCE_COMPENSATION + radius_compensation
	)
	$Environment/LoseLine/Line2D.position = Vector2(
		0, TILE_SIZE * 9 + FENCE_COMPENSATION + radius_compensation
	)
	if not GameMode.continuous:
		_state = GameState.POPPING
		for _i: int in range(5):
			balls.push_row()
			await balls.intermittent_move_done
		_state = GameState.WAITING


func _physics_process(delta: float) -> void:
	update_bouncer_status()
	var remaining_movement: float = _fly_speed * delta
	while _state == GameState.FLYING:
		assert(_flying_ball != null)
		if not get_viewport_rect().has_point(_flying_ball.position):
			await add_strike()
			_flying_ball.queue_free()
			_flying_ball = null
			_state = GameState.WAITING
			break
		var collision: KinematicCollision2D = _flying_ball.move_and_collide(
			_flying_ball.constant_linear_velocity * remaining_movement
		)
		if collision == null or collision.get_collider() == null:
			break
		elif collision.get_collider() != get_node("Environment/Edges"):
			_place_ball(collision)
			break
		else:
			# Bounce Ball
			remaining_movement = collision.get_remainder().length()
			_flying_ball.constant_linear_velocity = (
				_flying_ball
				. constant_linear_velocity
				. bounce(collision.get_normal())
			)
			break


func _place_ball(_collision: KinematicCollision2D) -> void:
	_state = GameState.POPPING
	var pop_queue_length := len(balls.pop_queue)
	balls.place_ball_collision(_flying_ball, _collision)
	_flying_ball = null
	var popped: int = maxi(len(balls.pop_queue) - pop_queue_length, 0)
	game_status.saved += popped
	if popped == 0:
		await add_strike()
	elif (
		(balls.balls_remaining <= (GameMode.difficulty_settings.row_size * 1.5))
		and not _in_warning
		and not GameMode.continuous
	):
		balls.push_row()
		await balls.intermittent_move_done
		game_status.strikes = 0
	_state = GameState.WAITING if _state != GameState.LOSE else _state


func update_bouncer_status() -> void:
	game_status.bouncer = clampf(
		remap(balls._row_offset, 0, -balls._ball_radius * sqrt(3), 0, 1), 0, 1
	)
	if balls._hex_grid_row_offset:
		game_status.bouncer = 1 - game_status.bouncer
	if _state == GameState.LOSE:
		game_status.bouncer = 0.5


func add_strike() -> void:
	if GameMode.continuous:
		return
	game_status.strikes += 1
	if game_status.strikes >= GameMode.difficulty_settings.allowed_strikes:
		balls.push_row()
		await balls.intermittent_move_done
		game_status.strikes = 0


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			launcher._current_angle_rad = launcher.position.angle_to_point(
				event.position
			)
			launcher.is_aiming = true
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.position.y >= 968:
				launcher.skip_ball()
				add_strike()
			else:
				launcher.fire()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			launcher.skip_ball()
			add_strike()
	elif event is InputEventMouseMotion:
		launcher._current_angle_rad = launcher.position.angle_to_point(
			event.position
		)
		launcher.is_aiming = true


func _on_ball_launcher_ball_fired(ball: Ball) -> void:
	ball.reparent(self)
	_flying_ball = ball
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
	game_over.emit()
	balls.max_speed = 88 * 2
	balls.mode = balls.MoveMode.CONTINUOUS
	$Environment/LoseLine.set_deferred("monitoring", false)


func _on_balls_row_pushed() -> void:
	if _state != GameState.LOSE:
		game_status.rows += 1
		game_status.strikes = 0


class GameStatus:
	var rows: int = 0
	var saved: int = 0:
		set(val):
			var change := val - saved
			saved = val
			score += floori((change * (change + 1)) / 2.0)

	var score: int = 0

	var strikes: int = 0  # Progress on intermittent
	var bouncer: float = 0.0  # Progress on continuous
