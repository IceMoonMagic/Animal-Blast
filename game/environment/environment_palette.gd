class_name EnvironmentPalette
extends Resource

enum Terrain { GRASS, SNOW, WATER, LAVA }

@export var normal_tiles: Terrain = Terrain.GRASS:
	set(terrain):
		if normal_tiles != terrain:
			normal_tiles = terrain
			emit_changed()
			print("changed")
@export var lose_tiles: Terrain = Terrain.WATER:
	set(terrain):
		if lose_tiles != terrain:
			lose_tiles = terrain
			emit_changed()
@export var defense_tiles: Terrain = Terrain.GRASS:
	set(terrain):
		if defense_tiles != terrain:
			defense_tiles = terrain
			emit_changed()

var is_liquid: Array:
	get:
		return [normal_tiles, lose_tiles, defense_tiles].map(
			func(t: Terrain) -> bool: return t in [Terrain.WATER, Terrain.LAVA]
		)
