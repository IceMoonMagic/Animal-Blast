extends Control

const ENVIRONMENT := preload("res://game/environment/environment.gd")
const ATLAS_MAP = ENVIRONMENT.ATLAS_MAP

var tiles: Rect2i = Rect2i(Vector2i.ZERO, Vector2i.ONE * 3)
@onready var menu_background_tile_map: TileMapLayer = %MenuBackgroundTileMap


func _enter_tree() -> void:
	get_viewport().size_changed.connect(update_offset)


func _ready() -> void:
	GameMode.environment_palette.connect("changed", update_palette)
	update_palette()
	update_offset()


func _exit_tree() -> void:
	get_viewport().size_changed.disconnect(update_offset)


func update_offset() -> void:
	var target_width := size.x
	var overflow := fposmod(target_width, 128)
	menu_background_tile_map.position.x = (overflow / 2) - 128


func update_palette() -> void:
	for x in range(tiles.size.x):
		for y in range(tiles.size.y):
			menu_background_tile_map.set_cell(
				Vector2i(tiles.position.x + x, tiles.position.y + y),
				0,
				ATLAS_MAP.get(GameMode.environment_palette.normal_tiles)
			)
