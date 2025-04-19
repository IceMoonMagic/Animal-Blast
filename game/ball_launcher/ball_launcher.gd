class_name BallLanucher
extends Node2D

signal ball_fired(ball: Ball)
const MAX_ANGLE_OFFSET = 60
const LAUNCH_SPEED = 6

var current_angle: float = 0:
	set(val):
		current_angle = clampf(
			val,
			-MAX_ANGLE_OFFSET + rotation_degrees,
			MAX_ANGLE_OFFSET + rotation_degrees
		)
var ball_current: Ball
var ball_on_deck: Ball
var can_fire := true
var _current_angle_rad: float:
	get:
		return deg_to_rad(current_angle)
	set(val):
		current_angle = rad_to_deg(val)


func _ready() -> void:
	if ball_on_deck == null:
		_cycle_balls()
	if ball_current == null:
		_cycle_balls()


func _cycle_balls() -> void:
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
	ball_current.constant_linear_velocity = (
		Vector2(cos(_current_angle_rad), sin(_current_angle_rad)) * LAUNCH_SPEED
	)
	ball_fired.emit(ball_current)
	_cycle_balls()


func skip_ball() -> void:
	if ball_current != null:
		ball_current.queue_free()
	_cycle_balls()
