extends Node2D

signal warning_triggered
signal warning_cleared
signal game_over

enum GameState { AIMING, FLYING, WAITING, WIN, LOSE }

var _in_warning := false
var _state := GameState.WAITING
var _fly_speed := 360.0
var _flying_ball: Ball


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


func _physics_process(delta: float) -> void:
	if _flying_ball == null:
		return
	var remaining_movement: float = _fly_speed * delta
	while true:
		var collision: KinematicCollision2D = _flying_ball.move_and_collide(
			_flying_ball.constant_linear_velocity * remaining_movement
		)
		if collision == null:
			break
		elif collision.get_collider() != get_node("Environment/Edges"):
			$Balls.place_ball(
				_flying_ball, $Balls.coords_to_index(_flying_ball.position)
			)
			_flying_ball = null
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
		_flying_ball = $Balls._init_ball()
		_flying_ball.constant_linear_velocity = Vector2(-2, -3).normalized()
		_flying_ball.position = event.position
		_flying_ball.set_collision_layer_value(1, false)
		_flying_ball.set_collision_mask_value(1, true)
		_flying_ball.set_collision_mask_value(2, true)
		add_child(_flying_ball)
		#_flying_ball.collision_shape.shape = _flying_ball.collision_shape.shape.duplicate()
		#_flying_ball.collision_shape.shape.radius *= .65


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
