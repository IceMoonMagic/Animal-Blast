extends Node

enum Difficulty { EASY, MEDIUM, HARD, CUSTOM }
const DIFFICUTLY_SETTINGS: Dictionary[Difficulty, GameDifficulty] = {
	Difficulty.EASY: preload("res://globals/game_difficulties/easy.tres"),
	Difficulty.MEDIUM: preload("res://globals/game_difficulties/medium.tres"),
	Difficulty.HARD: preload("res://globals/game_difficulties/hard.tres")
}
const BallScene = preload("res://game/balls/ball.tscn")

var animal_palette: AnimalPalette = AnimalPalette.new()
var environment_palette: EnvironmentPalette = EnvironmentPalette.new()
var continuous := false
var custom_difficulty: GameDifficulty = (
	DIFFICUTLY_SETTINGS[Difficulty.MEDIUM].duplicate()
)
var difficulty: Difficulty = Difficulty.EASY
var difficulty_settings: GameDifficulty:
	get:
		if difficulty == Difficulty.CUSTOM:
			return custom_difficulty
		return DIFFICUTLY_SETTINGS[difficulty]

var ball_radius: float:
	get:
		return 640.0 / (2 * difficulty_settings.row_size + 1)


func init_ball(
	spin_direction: int = [-1, 1].pick_random(),
) -> Ball:
	var ball := BallScene.instantiate()
	ball.animal = (
		animal_palette
		. get_limited(difficulty_settings.palette_size)
		. pick_random()
	)
	ball.radius = ball_radius
	ball.constant_angular_velocity = spin_direction
	return ball
