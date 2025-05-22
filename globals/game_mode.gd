extends Node

enum Difficulty { EASY, MEDIUM, HARD, CUSTOM }
const DIFFICUTLY_SETTINGS: Dictionary[Difficulty, GameDifficulty] = {
	Difficulty.EASY: preload("res://globals/game_difficulties/easy.tres"),
	Difficulty.MEDIUM: preload("res://globals/game_difficulties/medium.tres"),
	Difficulty.HARD: preload("res://globals/game_difficulties/hard.tres")
}
const BallScene = preload("res://game/balls/ball.tscn")

@export_storage var animal_palette: AnimalPalette = AnimalPalette.new()
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


#
func _enter_tree() -> void:
	load_config_file()


func _exit_tree() -> void:
	save_config_file()


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


func load_config_file() -> Error:
	var config_file := ConfigFile.new()
	var err := config_file.load("user://config.cfg")
	if err != OK:
		return err

	animal_palette.animals = config_file.get_value(
		"GameMode", "animals", animal_palette.animals
	)
	var env_palette: Array = config_file.get_value(
		"GameMode", "tiles", [0, 2, 0]
	)
	environment_palette.normal_tiles = (
		env_palette[0] as EnvironmentPalette.Terrain
	)
	environment_palette.lose_tiles = (
		env_palette[1] as EnvironmentPalette.Terrain
	)
	environment_palette.defense_tiles = (
		env_palette[2] as EnvironmentPalette.Terrain
	)
	continuous = config_file.get_value("GameMode", "continuous", continuous)

	var cust_diff: Array = config_file.get_value(
		"GameMode",
		"custom_difficulty",
		[
			custom_difficulty.allowed_strikes,
			custom_difficulty.continuous_speed,
			custom_difficulty.palette_size,
			custom_difficulty.row_size
		]
	)
	custom_difficulty.allowed_strikes = roundi(cust_diff[0])
	custom_difficulty.continuous_speed = cust_diff[1]
	custom_difficulty.palette_size = roundi(cust_diff[2])
	custom_difficulty.row_size = roundi(cust_diff[3])

	return OK


func save_config_file() -> Error:
	var config_file := ConfigFile.new()
	config_file.set_value("GameMode", "animals", animal_palette.animals)
	config_file.set_value(
		"GameMode",
		"tiles",
		[
			environment_palette.normal_tiles,
			environment_palette.lose_tiles,
			environment_palette.defense_tiles
		]
	)
	config_file.set_value("GameMode", "continuous", continuous)
	config_file.set_value(
		"GameMode",
		"custom_difficulty",
		[
			custom_difficulty.allowed_strikes,
			custom_difficulty.continuous_speed,
			custom_difficulty.palette_size,
			custom_difficulty.row_size
		]
	)
	return config_file.save("user://config.cfg")
