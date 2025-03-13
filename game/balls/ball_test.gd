# GdUnit generated TestSuite
class_name BallTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")
# TestSuite generated from
# gdlint:ignore = constant-name
const __source = "res://game/balls/ball.gd"
const BallScene = preload("res://game/balls/ball.tscn")

var ball: Ball


func before_test() -> void:
	ball = auto_free(BallScene.instantiate())
	get_tree().root.add_child(ball)


func test_get_variant_saves_result() -> void:
	Ball.variants.clear()
	var first_call: Ball.BallVariant = Ball.get_variant(Ball.Animal.BEAR)
	assert_object(first_call).is_not_null()
	assert_object(Ball.get_variant(Ball.Animal.BEAR)).is_same(first_call)


func test_get_variant_each_works_and_unique() -> void:
	var seen: Array[Ball.BallVariant] = []
	for animal: Ball.Animal in Ball.Animal.values():
		var result: Ball.BallVariant = Ball.get_variant(animal)
		assert_object(result).is_instanceof(Ball.BallVariant)
		assert_array(seen).not_contains_same([result])
		seen.append(result)


func test_pop_changes_sprit() -> void:
	assert_object(ball.sprite.texture).is_same(ball.ball_variant.ball_form)
	ball.pop()
	assert_object(ball.sprite.texture).is_same(ball.ball_variant.popped_form)


func test_pop_enables_gravity() -> void:
	assert_float(ball.gravity_scale).is_equal(0.0)
	ball.pop()
	assert_float(ball.gravity_scale).is_equal(-1.0)


func test_pop_doesnt_stack_gravity() -> void:
	assert_float(ball.gravity_scale).is_equal(0.0)
	ball.pop()
	ball.pop()
	assert_float(ball.gravity_scale).is_equal(-1.0)


func test_pop_disables_collision() -> void:
	assert_bool(ball.collision_shape.disabled).is_false()
	ball.pop()
	assert_bool(ball.collision_shape.disabled).is_true()
