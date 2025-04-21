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
var can_fire := true
var _current_angle_rad: float:
	get:
		return deg_to_rad(current_angle)
	set(val):
		current_angle = rad_to_deg(val)
var _fire_normal: Vector2:
	get:
		return Vector2(cos(_current_angle_rad), sin(_current_angle_rad))


func _ready() -> void:
	$Line2D/ShapeCast2D.shape.radius = GameMode.ball_radius
	if ball_on_deck == null:
		cycle_balls()
	if ball_current == null:
		cycle_balls()


func _physics_process(_delta: float) -> void:
	$Line2D.visible = can_fire
	_current_angle_rad = (get_global_mouse_position() - position).angle()
	$Line2D/ShapeCast2D.position = Vector2.ZERO
	$Line2D/ShapeCast2D.target_position = _fire_normal.rotated(-rotation) * 2000
	$Line2D.set_point_position(
		1,
		(
			$Line2D/ShapeCast2D.get_closest_collision_unsafe_fraction()
			* $Line2D/ShapeCast2D.target_position
		)
	)

	if not $Line2D/ShapeCast2D.is_colliding():
		if $Line2D.get_point_count() > 2:
			$Line2D.remove_point(2)
		return
	var collider: CollisionObject2D = $Line2D/ShapeCast2D.get_collider(0)
	if collider != null and collider.get_collision_layer_value(2):
		pass


func cycle_balls() -> void:
	ball_current = ball_on_deck
	ball_on_deck = GameMode.init_ball()
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

	can_fire = false
	ball_current.constant_linear_velocity = _fire_normal * LAUNCH_SPEED
	ball_fired.emit(ball_current)
	cycle_balls()


func skip_ball() -> void:
	if ball_current != null:
		ball_current.queue_free()
	cycle_balls()
