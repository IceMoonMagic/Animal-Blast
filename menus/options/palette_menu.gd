class_name PaletteMenu
extends Control

@onready var normal_tile_option: OptionButton = %NormalTileOption
@onready var lose_tile_option: OptionButton = %LoseTileOption
@onready var defense_tile_option: OptionButton = %DefenseTileOption

@onready var animal_option_buttons: Array[OptionButton] = [%AnimalPaletteOption]
@onready var back_button: Button = %BackButton


func _ready() -> void:
	GameMode.load_config_file()
	normal_tile_option.selected = GameMode.environment_palette.normal_tiles
	lose_tile_option.selected = GameMode.environment_palette.lose_tiles - 2
	defense_tile_option.selected = GameMode.environment_palette.defense_tiles

	for animal_index: int in len(Ball.Animal):
		var icon := Ball.get_variant(animal_index as Ball.Animal).ball_form
		animal_option_buttons[0].add_icon_item(icon, "")

	for i in range(8 - 1):
		var dupe: OptionButton = animal_option_buttons[0].duplicate(0)
		animal_option_buttons.insert(1, dupe)
		animal_option_buttons[0].add_sibling(dupe)

	for i in range(8):
		var button: OptionButton = animal_option_buttons[i]
		button.selected = GameMode.animal_palette.animals[i]
		button.connect(
			"item_selected", _on_animal_palette_option_item_elected.bind(i)
		)
	_update_disabled_animals()


func _update_disabled_animals() -> void:
	for animal_index: int in len(Ball.Animal):
		var disabled: bool = animal_index in GameMode.animal_palette.animals
		for button: OptionButton in animal_option_buttons:
			button.set_item_disabled(animal_index, disabled)


func _on_normal_tile_option_item_selected(index: int) -> void:
	GameMode.environment_palette.normal_tiles = (
		index as EnvironmentPalette.Terrain
	)


func _on_lose_tile_option_item_selected(index: int) -> void:
	GameMode.environment_palette.lose_tiles = (
		index + 2 as EnvironmentPalette.Terrain
	)


func _on_defense_tile_option_item_selected(index: int) -> void:
	GameMode.environment_palette.defense_tiles = (
		index as EnvironmentPalette.Terrain
	)


func _on_animal_palette_option_item_elected(
	item_index: int, button_index: int
) -> void:
	GameMode.animal_palette.animals[button_index] = item_index as Ball.Animal
	_update_disabled_animals()


func _on_back_button_pressed() -> void:
	GameMode.save_config_file()
	get_tree().change_scene_to_file("res://menus/title_screen.tscn")
