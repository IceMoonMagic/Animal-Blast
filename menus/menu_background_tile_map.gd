extends TileMapLayer

const ENVIRONMENT := preload("res://game/environment/environment.gd")
const ATLAS_MAP = ENVIRONMENT.ATLAS_MAP

@export var tiles: Rect2i = Rect2i(Vector2i.ZERO, Vector2i.ONE)


func _ready() -> void:
	GameMode.environment_palette.connect("changed", update_palette)
	update_palette()


func update_palette() -> void:
	for x in range(tiles.size.x):
		for y in range(tiles.size.y):
			set_cell(
				Vector2i(tiles.position.x + x, tiles.position.y + y),
				0,
				ATLAS_MAP.get(GameMode.environment_palette.normal_tiles)
			)
