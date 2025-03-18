extends Node2D

## The balls, using pointy-top hexagon doubled cooridnates.
## [br]https://www.redblobgames.com/grids/hexagons/#coordinates-doubled
const BallScene = preload("res://game/balls/ball.tscn")
var balls: Array[Array] = []
## How many balls fit in a row. Visually, each row could hold another half ball
var row_size: int = 5
## Animals allowed to be used
var animal_pallete: Array[Ball.Animal] = [Ball.Animal.PENGUIN]
var _row_offset: float = 0.0


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


func _physics_process(_delta: float) -> void:
	for rows: Array[Ball] in balls:
		for ball: Ball in rows:
			if ball != null:
				ball.position += Vector2.DOWN
				ball.rotation_degrees += clampf(ball.angular_velocity, -1, 1)
	_row_offset += 1
	if _row_offset >= 0:
		push_row()
		_row_offset = -68 * sqrt(3)
	if len(balls) > 6:
		for ball: Ball in balls[-1]:
			if ball != null:
				ball.pop()
				ball.freeze = false
		balls.pop_back()


func push_row() -> void:
	var result: Array[Ball] = []
	result.resize(row_size * 2)
	result.fill(null)

	var offset := int(len(balls) != 0 and balls[0][0] != null)
	for x: int in range(offset, row_size * 2, 2):
		var ball: Ball = BallScene.instantiate()
		ball.animal = animal_pallete.pick_random()
		ball.freeze = true
		ball.position = Vector2(x * 68 + 68, -68)
		ball.angular_velocity = -1 if bool(offset) else 1
		$Balls.add_child(ball)
		result[x] = ball

	balls.push_front(result)
