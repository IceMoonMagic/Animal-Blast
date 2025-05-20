class_name BallLanucher
extends Node2D

signal ball_fired(ball: Ball)
const MAX_ANGLE_OFFSET = 60
const LAUNCH_SPEED = 6

var current_angle: float = 0:
	set(val):
		var wrap_at: float = rotation_degrees + 180
		var adjusted_angle := fposmod(val - wrap_at, 360)
		var clamped_angle := clampf(
			adjusted_angle,
			fposmod(rotation_degrees - MAX_ANGLE_OFFSET - wrap_at, 360),
			fposmod(rotation_degrees + MAX_ANGLE_OFFSET - wrap_at, 360)
		)
		current_angle = fposmod(clamped_angle + wrap_at, 360)
var ball_current: Ball
var ball_on_deck: Ball
var can_fire := true:
	set(val):
		can_fire = val
		is_aiming = can_fire and is_aiming
		if ball_current != null:
			if can_fire:
				ball_current.position = Vector2i.ZERO  # Position of marker_2d
			else:
				ball_current.global_position = self.global_position
var is_aiming := false:
	set(val):
		is_aiming = can_fire and val
		line2d.visible = is_aiming

var _current_angle_rad: float:
	get:
		return deg_to_rad(current_angle)
	set(val):
		current_angle = rad_to_deg(val)
var _fire_normal: Vector2:
	get:
		return Vector2(cos(_current_angle_rad), sin(_current_angle_rad))
var _ball_random_pool: RandomPool

@onready var spare_holder: Sprite2D = $SpareHolder
@onready var line2d: Line2D = $Line2D
@onready var shape_cast: ShapeCast2D = $Line2D/ShapeCast2D
@onready var pivot: Node2D = $Pivot
@onready var launcher_arrow: Sprite2D = $Pivot/LauncherArrow
@onready var marker_2d: Marker2D = $Pivot/LauncherArrow/Marker2D


func _ready() -> void:
	_ball_random_pool = RandomPool.new(
		GameMode.animal_palette.get_limited(
			GameMode.difficulty_settings.palette_size
		),
		GameMode.difficulty_settings.palette_size * 2 - 2
	)
	for animal: Ball.Animal in _ball_random_pool.items.duplicate():
		_ball_random_pool.items.append(animal)

	spare_holder.scale = (
		Vector2.ONE / spare_holder.get_rect().size * (GameMode.ball_radius * 3)
	)
	shape_cast.shape.radius = GameMode.ball_radius
	line2d.width = GameMode.ball_radius * 2
	launcher_arrow.position.y = GameMode.ball_radius * 2
	marker_2d.position.y = (
		-launcher_arrow.position.y
		- launcher_arrow.get_rect().size.y / 2
		+ GameMode.ball_radius
	)
	if ball_on_deck == null:
		cycle_balls()
	if ball_current == null:
		cycle_balls()

	current_angle = rotation_degrees


func _physics_process(_delta: float) -> void:
	const LINE_LENGTH := 2000

	pivot.rotation = _current_angle_rad

	shape_cast.position = Vector2.ZERO
	shape_cast.target_position = _fire_normal.rotated(-rotation) * LINE_LENGTH
	shape_cast.force_shapecast_update()
	line2d.clear_points()
	line2d.add_point(
		(marker_2d.global_position - line2d.global_position).rotated(-rotation)
	)
	line2d.add_point(
		(
			shape_cast.get_closest_collision_unsafe_fraction()
			* shape_cast.target_position
		)
	)
	if not shape_cast.is_colliding():
		return
	var collider: CollisionObject2D = shape_cast.get_collider(0)
	if collider == null or not collider.get_collision_layer_value(2):
		return

	shape_cast.target_position = (
		_fire_normal.rotated(-rotation).reflect(
			shape_cast.get_collision_normal(0)
		)
		* LINE_LENGTH
	)
	shape_cast.position = line2d.points[-1]
	shape_cast.force_shapecast_update()

	var start_point := shape_cast.position
	var end_point := shape_cast.target_position + shape_cast.position
	var collision_point: Vector2 = (
		(
			(end_point - start_point)
			* shape_cast.get_closest_collision_safe_fraction()
		)
		+ start_point
	)
	line2d.add_point(collision_point)


func cycle_balls() -> void:
	ball_current = ball_on_deck
	if ball_current != null:
		ball_current.reparent(marker_2d, false)
	ball_on_deck = GameMode.init_ball()
	ball_on_deck.animal = _ball_random_pool.get_item()
	ball_on_deck.rotation = -rotation
	ball_on_deck.set_collision_layer_value(1, false)
	ball_on_deck.set_collision_mask_value(1, true)
	ball_on_deck.set_collision_mask_value(2, true)
	ball_on_deck.z_index = 1
	add_child(ball_on_deck)
	move_child(ball_on_deck, 0)


func fire(force := false) -> void:
	if not can_fire and not force:
		return

	var firing := ball_current
	cycle_balls()
	firing.constant_linear_velocity = _fire_normal * LAUNCH_SPEED
	ball_fired.emit(firing)


func skip_ball() -> void:
	if ball_current != null:
		ball_current.queue_free()
	cycle_balls()
