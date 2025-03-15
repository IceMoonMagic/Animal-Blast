@tool
extends Node2D

enum Terrain { GRASS, SNOW, WATER, LAVA }

@export var normal_tiles: Terrain = Terrain.GRASS:
	set(tile):
		normal_tiles = tile
		_set_cells_between(Vector2i.ZERO, Vector2i(4, 8), normal_tiles)
@export var lose_tiles: Terrain = Terrain.WATER:
	set(tile):
		lose_tiles = tile
		_set_cells_between(Vector2i(0, 9), Vector2i(4, 10), lose_tiles)
@export var defense_tiles: Terrain = Terrain.GRASS:
	set(tile):
		defense_tiles = tile
		_set_cells_between(Vector2i(0, 11), Vector2i(4, 11), defense_tiles)

@onready var tile_map_layer: TileMapLayer = $TileMapLayer


func _set_cells_between(start: Vector2i, end: Vector2i, terrain: int) -> void:
	if not is_node_ready() and not Engine.is_editor_hint():
		await ready
	var cells: Array[Vector2i] = _cells_between(start, end)
	tile_map_layer.set_cells_terrain_connect(cells, 0, terrain)


func _cells_between(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for x in range(end.x - start.x + 1):
		for y in range(end.y - start.y + 1):
			result.append(Vector2i(x + start.x, y + start.y))
	return result
