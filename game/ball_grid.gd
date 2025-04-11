extends Node2D
## The grid of balls, using pointy-top hexagon doubled cooridnates.
## [br]https://www.redblobgames.com/grids/hexagons/#coordinates-doubled

## Emitted when mode changes off of INTERMITTENT_MOVE
signal intermittent_move_done
enum MoveMode { CONTINUOUS, INTERMITTENT_WAIT, INTERMITTENT_MOVE }
const BallScene = preload("res://game/balls/ball.tscn")

## How many balls fit in a row. Visually, each row could hold another half ball
@export var row_size: int = 10:
	set(val):
		row_size = abs(val)
@export var acceleration: float = 1
@export var max_speed: float = 30
@export var mode: MoveMode = MoveMode.CONTINUOUS:
	set(new_mode):
		match new_mode:
			MoveMode.CONTINUOUS:
				pass
			MoveMode.INTERMITTENT_MOVE:
				_speed = max_speed
				if _row_offset >= 0:
					push_row()
			MoveMode.INTERMITTENT_WAIT:
				_speed = 0
		if mode == MoveMode.INTERMITTENT_MOVE and mode != new_mode:
			intermittent_move_done.emit()
		mode = new_mode
## Animals allowed to be used
var animal_pallete: Array[Ball.Animal] = [Ball.Animal.PENGUIN]
var balls: Array[Array] = []
var _row_offset: float = 0.0
var _ball_radius: float:
	get:
		return 640.0 / (2 * row_size + 1)
var _speed: float = 0
var _hex_grid_row_offset: bool = false


#region Get Adjacent Hexagon Cell
static func get_left_up(from: Vector2i) -> Vector2i:
	return from - Vector2i.ONE


static func get_left_left(from: Vector2i) -> Vector2i:
	return from + Vector2i(-2, 0)


static func get_left_down(from: Vector2i) -> Vector2i:
	return from + Vector2i(-1, 1)


static func get_right_up(from: Vector2i) -> Vector2i:
	return from + Vector2i(1, -1)


static func get_right_right(from: Vector2i) -> Vector2i:
	return from + Vector2i(2, 0)


static func get_right_down(from: Vector2i) -> Vector2i:
	return from + Vector2i.ONE


#endregion

@warning_ignore("shadowed_variable")


func _init(
	row_size: int = self.row_size,
	animal_pallete: Array[Ball.Animal] = self.animal_pallete
) -> void:
	self.row_size = row_size
	self.animal_pallete = animal_pallete


#region Row Movement
func _physics_process(delta: float) -> void:
	if mode == MoveMode.INTERMITTENT_WAIT:
		return
	roll_rows(_speed * delta)
	_speed = min(max_speed, _speed + acceleration)
	if _row_offset >= 0:
		if mode == MoveMode.CONTINUOUS:
			push_row()
		else:
			mode = MoveMode.INTERMITTENT_WAIT
	if (sqrt(3) * len(balls) - 2) * _ball_radius + _row_offset > 1111:
		for ball: Ball in balls.pop_back():
			if ball != null:
				ball.queue_free()


func advance(block: bool = true) -> void:
	mode = MoveMode.INTERMITTENT_MOVE
	if block:
		await intermittent_move_done


func roll_rows(distance: float) -> void:
	for rows: Array[Ball] in balls:
		for ball: Ball in rows:
			if ball != null:
				ball.move_and_collide(Vector2.DOWN * distance)
				ball.rotation += (
					ball.constant_angular_velocity * (distance / _ball_radius)
				)
	_row_offset += distance


func push_row() -> void:
	var result: Array[Ball] = []
	result.resize(row_size * 2)
	result.fill(null)

	_hex_grid_row_offset = not _hex_grid_row_offset
	for x: int in range(int(_hex_grid_row_offset), row_size * 2, 2):
		var ball: Ball = BallScene.instantiate()
		ball.animal = animal_pallete.pick_random()
		ball.position = Vector2(
			_ball_radius * (x + 1),
			_row_offset - _ball_radius,
		)
		ball.constant_angular_velocity = -1 if _hex_grid_row_offset else 1
		ball.rotation = randf_range(0, 2 * PI)
		ball.radius = _ball_radius
		add_child(ball)
		result[x] = ball

	balls.push_front(result)
	_row_offset -= _ball_radius * sqrt(3)


#endregion


#region Coordinate Conversion
func coords_to_index(coords: Vector2) -> Vector2i:
	var original_coords := coords
	#coords.x -= _ball_radius
	coords.x /= _ball_radius
	coords.x -= 1
	#coords.y += _row_offset
	coords.y /= (_ball_radius * sqrt(3))
	var result_coords := Vector2i(coords.round())
	if (result_coords.x + result_coords.y) % 2 == int(_hex_grid_row_offset):
		return result_coords

	var canidates: Array[Vector2i] = [
		result_coords + Vector2i.UP,
		result_coords + Vector2i.DOWN,
		result_coords + Vector2i.LEFT,
		result_coords + Vector2i.RIGHT,
	]
	var closest_distance := INF
	var closest_coords: Vector2i
	for canidate: Vector2i in canidates:
		if (canidate.x + canidate.y) % 2 != int(_hex_grid_row_offset):
			continue
		var canidate_position: Vector2 = index_to_coords(canidate)
		var distance: float = original_coords.distance_squared_to(
			canidate_position
		)
		if distance < closest_distance:
			closest_distance = distance
			closest_coords = canidate
	return closest_coords


func index_to_coords(index: Vector2i) -> Vector2:
	return Vector2(
		(index.x + 1) * _ball_radius,
		(index.y + 1) * _ball_radius * sqrt(3) + _row_offset - _ball_radius
	)


func is_in_bounds(index: Vector2i) -> bool:
	return (
		0 <= index.y
		and index.y < len(balls)
		and 0 <= index.x
		and index.x < len(balls[index.y])
	)


func ball_exists(index: Vector2i) -> bool:
	return is_in_bounds(index) and balls[index.y][index.x] != null

#endregion
