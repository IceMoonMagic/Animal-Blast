class_name BallGrid
extends Node2D
## The grid of balls, using pointy-top hexagon doubled cooridnates.
## [br]https://www.redblobgames.com/grids/hexagons/#coordinates-doubled

## Emitted when mode changes off of INTERMITTENT_MOVE
signal intermittent_move_done
signal row_pushed
enum MoveMode { CONTINUOUS, INTERMITTENT_WAIT, INTERMITTENT_MOVE }

## How many balls fit in a row. Visually, each row could hold another half ball
@export var row_size: int:
	get:
		return GameMode.difficulty_settings.row_size
@export var acceleration: float = 1
@export var mode: MoveMode = (
	MoveMode.CONTINUOUS if GameMode.continuous else MoveMode.INTERMITTENT_WAIT
):
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
			intermittent_move_done.emit.call_deferred()
		mode = new_mode
var max_speed: float:
	get:
		if get_parent()._state == Game.GameState.LOSE:
			return GameMode.ball_radius * 10
		elif GameMode.continuous:
			if balls_remaining < GameMode.difficulty_settings.row_size * 2.5:
				return _ball_radius * 1.5
			return GameMode.difficulty_settings.continuous_speed
		else:
			return _ball_radius * 1.5
## Animals allowed to be used
var pop_queue: Array[Ball] = []
var balls: Array[Array] = []
var balls_remaining: int:
	get:
		var counter: int = 0
		for row: Array[Ball] in balls:
			for ball: Ball in row:
				if ball != null:
					counter += 1
		return counter
var _row_offset: float = 0.0
var _ball_radius: float = GameMode.ball_radius
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


static func get_adjacent_cells(from: Vector2i) -> Array[Vector2i]:
	return [
		get_left_down(from),
		get_left_left(from),
		get_left_up(from),
		get_right_down(from),
		get_right_right(from),
		get_right_up(from),
	]


#endregion


#region Row Movement
func _physics_process(delta: float) -> void:
	var to_pop: Ball = pop_queue.pop_front()
	if to_pop != null:
		to_pop.pop()
	if mode == MoveMode.INTERMITTENT_WAIT:
		return
	roll_rows(_speed * delta)
	_speed = move_toward(_speed, max_speed, acceleration)
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
				ball.position += (Vector2.DOWN * distance)
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
		var ball: Ball = GameMode.init_ball(-1 if _hex_grid_row_offset else 1)
		ball.rotation = randf_range(0, 2 * PI)
		ball.position = Vector2(
			_ball_radius * (x + 1),
			_row_offset - _ball_radius,
		)

		var balls_down := [
			get_left_down(Vector2i(x, -1)), get_right_down(Vector2i(x, -1))
		]
		balls_down.shuffle()
		for adjacent: Vector2i in balls_down:
			var num_same_animal := len(
				find_adjacent_cells_same_animal(adjacent)
			)
			if 0 < num_same_animal and num_same_animal < 2:
				ball.animal = balls[adjacent.y][adjacent.x].animal
				break

		add_child(ball)
		result[x] = ball

	balls.push_front(result)
	_row_offset -= _ball_radius * sqrt(3)
	if mode == MoveMode.INTERMITTENT_WAIT:
		mode = MoveMode.INTERMITTENT_MOVE
	row_pushed.emit()


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


func get_surrounding_cells(
	base_cells: Array[Vector2i], include_empty: bool = false
) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for base_cell: Vector2i in base_cells:
		for adjacent_cell in get_adjacent_cells(base_cell):
			if (
				is_in_bounds(adjacent_cell)
				and adjacent_cell not in base_cells
				and adjacent_cell not in result
				and (
					include_empty
					or balls[adjacent_cell.y][adjacent_cell.x] != null
				)
			):
				result.append(adjacent_cell)
	return result


func find_adjacent_cells(
	starting_index: Vector2i, condition: Callable
) -> Array[Vector2i]:
	var explored: Array[Vector2i] = []
	var _find_adjacent_balls: Callable
	_find_adjacent_balls = func(
		index: Vector2i, recurse: Callable
	) -> Array[Vector2i]:
		if (
			index in explored
			or not ball_exists(index)
			or not condition.call(index, balls[index.y][index.x])
		):
			return []
		explored.append(index)

		var result: Array[Vector2i] = [index]
		for next_index: Vector2i in get_adjacent_cells(index):
			result.append_array(recurse.call(next_index, recurse))
		return result
	return _find_adjacent_balls.call(starting_index, _find_adjacent_balls)


func find_adjacent_cells_same_animal(
	starting_index: Vector2i
) -> Array[Vector2i]:
	if not ball_exists(starting_index):
		return []
	var target_animal: Ball.Animal = (
		balls[starting_index.y][starting_index.x].animal
	)
	var cond_same_animal := func(_pos: Vector2i, ball: Ball) -> bool:
		return target_animal == ball.animal
	return find_adjacent_cells(starting_index, cond_same_animal)


func pop_balls(cluster: Array[Vector2i]) -> void:
	for ball_index: Vector2i in cluster:
		if not ball_exists(ball_index):
			continue
		var ball: Ball = balls[ball_index.y][ball_index.x]
		balls[ball_index.y][ball_index.x] = null
		pop_queue.append(ball)


func pop_match_3(index: Vector2i) -> void:
	var poppable_balls: Array[Vector2i] = find_adjacent_cells_same_animal(index)
	if len(poppable_balls) < 3:
		return
	pop_balls(poppable_balls)
	for adjacent in get_surrounding_cells(poppable_balls):
		pop_ungrounded(adjacent)


func pop_ungrounded(index: Vector2i) -> void:
	if not ball_exists(index):
		return
	var cluster: Array[Vector2i] = find_adjacent_cells(
		index, func(_i: Vector2i, _b: Ball) -> bool: return true
	)
	if not cluster.any(func(i: Vector2i) -> bool: return i.y == 0):
		pop_balls(cluster)


func place_ball_collision(ball: Ball, collision: KinematicCollision2D) -> void:
	assert(is_instance_of(collision.get_collider(), Ball))
	var hit_ball: Ball = collision.get_collider()
	var hit_index: Vector2i = coords_to_index(hit_ball.position)
	assert(balls[hit_index.y][hit_index.x] == hit_ball)
	var raw_collision_angle := fposmod(
		rad_to_deg(hit_ball.position.angle_to_point(ball.position)), 360
	)
	var collision_angle := fposmod(raw_collision_angle + 30, 360)
	var collision_zone := floori(collision_angle / 60)
	var place_index: Vector2i
	match collision_zone:
		0:
			place_index = get_right_right(hit_index)
		1:
			place_index = get_right_down(hit_index)
		2:
			place_index = get_left_down(hit_index)
		3:
			place_index = get_left_left(hit_index)
		4:
			place_index = get_left_up(hit_index)
		5:
			place_index = get_right_up(hit_index)
		_:
			push_error(
				"collision_zone ({}) out of bounds".format([collision_zone])
			)
			assert(false)
			place_index = get_right_right(hit_index)

	assert(
		(
			place_index.y >= len(balls)
			or balls[place_index.y][place_index.x] == null
		)
	)
	place_ball(ball, place_index)


func place_ball(ball: Ball, index: Vector2i, cause_pop := true) -> void:
	if (
		index.y < 0
		or index.x < 0
		or index.x >= row_size * 2
		or ball_exists(index)
	):
		ball.queue_free()
		return

	for _i in range(max(0, index.y - len(balls) + 1)):
		var filler_array: Array = []
		filler_array.resize(row_size * 2)
		filler_array.fill(null)
		balls.append(filler_array)

	balls[index.y][index.x] = ball

	ball.reparent(self)
	ball.set_collision_layer_value(1, true)
	ball.set_collision_mask_value(1, false)
	ball.set_collision_mask_value(2, false)
	ball.z_index = 0
	ball.position = index_to_coords(index)
	if cause_pop:
		pop_match_3(index)
