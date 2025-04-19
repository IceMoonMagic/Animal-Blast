extends Node

enum DIFFICULTY { EASY, MEDIUM, HARD }
const DIFFICUTLY_SETTINGS: Dictionary = {
	DIFFICULTY.EASY:
	{
		num_animals = 4,
		num_rows = 7,
	},
	DIFFICULTY.MEDIUM:
	{
		num_animals = 6,
		num_rows = 10,
	},
	DIFFICULTY.HARD:
	{
		num_animals = 8,
		num_rows = 15,
	}
}
const BallScene = preload("res://game/balls/ball.tscn")

var animal_palette: AnimalPalette = AnimalPalette.new()
var environment_palette: EnvironmentPalette = EnvironmentPalette.new()
var difficulty: DIFFICULTY = DIFFICULTY.EASY
var difficulty_settings: Dictionary:
	get:
		return DIFFICUTLY_SETTINGS[difficulty]


func init_ball(
	spin_direction: int = [-1, 1].pick_random(),
) -> Ball:
	var ball := BallScene.instantiate()
	ball.animal = (
		animal_palette
		. get_limited(difficulty_settings["num_animals"])
		. pick_random()
	)
	ball.radius = 640.0 / (2 * difficulty_settings["num_rows"] + 1)
	ball.constant_angular_velocity = spin_direction
	return ball
