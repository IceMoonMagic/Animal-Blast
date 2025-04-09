@tool
extends Node2D

enum Terrain { GRASS, SNOW, WATER, LAVA }
const ATLAS_MAP: Dictionary[Terrain, Vector2i] = {
	Terrain.GRASS: Vector2i(0, 0),
	Terrain.SNOW: Vector2i(1, 0),
	Terrain.WATER: Vector2i(0, 1),
	Terrain.LAVA: Vector2i(0, 2),
}

@export var normal_tiles: Terrain = Terrain.GRASS:
	set(tile):
		normal_tiles = tile
		_set_cells_between(Vector2i(0, -1), Vector2i(4, 8), normal_tiles)
		_update_midground()
@export var lose_tiles: Terrain = Terrain.WATER:
	set(tile):
		lose_tiles = tile
		_update_midground()
@export var defense_tiles: Terrain = Terrain.GRASS:
	set(tile):
		defense_tiles = tile
		_set_cells_between(Vector2i(0, 11), Vector2i(4, 11), defense_tiles)
		_update_midground()

@onready var background: Node2D = $Background
@onready
var background_tile_map_layer: TileMapLayer = $Background/BackgroundTileMapLayer
@onready var defence_fences: Node2D = $Foreground/DefenceFences
@onready var foreground: Node2D = $Foreground
@onready
var foreground_tile_map_layer: TileMapLayer = $Foreground/ForegroundTileMapLayer
@onready var final_fences: Node2D = $Background/FinalFences


func _update_midground() -> void:
	if not is_node_ready():
		await ready

	const FENCE_OFFSET := 20.0
	var is_liquid: Array = [normal_tiles, lose_tiles, defense_tiles].map(
		func(t: Terrain) -> bool: return t in [Terrain.WATER, Terrain.LAVA]
	)
	var layer_switch: int = 9
	match is_liquid:
		[false, false, false]:  # Field
			foreground.z_index = 0
			#layer_switch = 9
			final_fences.visible = true
			final_fences.position.y = 0
			final_fences.z_index = 0
			final_fences.process_mode = Node.PROCESS_MODE_INHERIT
			defence_fences.visible = false
			#defence_fences.position.y = 0
		[false, true, false]:  # River
			foreground.z_index = 1
			layer_switch = 9
			final_fences.visible = true
			final_fences.position.y = 0
			final_fences.z_index = 0
			final_fences.process_mode = Node.PROCESS_MODE_INHERIT
			defence_fences.visible = true
			defence_fences.position.y = 0
		[false, false, true]:  # Small Shore
			foreground.z_index = 0
			#layer_switch = 9
			final_fences.visible = true
			final_fences.position.y = 0
			final_fences.z_index = 0
			final_fences.process_mode = Node.PROCESS_MODE_INHERIT
			defence_fences.visible = true
			defence_fences.position.y = -FENCE_OFFSET
		[false, true, true]:  # Big Shore
			foreground.z_index = 1
			layer_switch = 8
			final_fences.visible = true
			final_fences.position.y = 0
			final_fences.z_index = 0
			final_fences.process_mode = Node.PROCESS_MODE_INHERIT
			defence_fences.visible = false
			#defence_fences.position.y = 0
		[true, true, true]:  # Ocean
			foreground.z_index = 0
			#layer_switch = 9
			final_fences.visible = false
			#final_fences.position.y = 0
			#final_fences.z_index = 0
			#final_fences.process_mode = Node.PROCESS_MODE_INHERIT
			defence_fences.visible = false
			#defence_fences.position.y = 0
		[true, false, true]:  # Bridge
			foreground.z_index = 1
			layer_switch = 8
			final_fences.visible = true
			final_fences.position.y = FENCE_OFFSET
			final_fences.z_index = 1
			final_fences.process_mode = Node.PROCESS_MODE_DISABLED
			defence_fences.visible = true
			defence_fences.position.y = -FENCE_OFFSET
		[true, true, false]:  # Big Sea
			foreground.z_index = 1
			layer_switch = 9
			final_fences.visible = false
			#final_fences.position.y = 0
			#final_fences.z_index = 0
			#final_fences.process_mode = Node.PROCESS_MODE_INHERIT
			defence_fences.visible = true
			defence_fences.position.y = 0
		[true, false, false]:  # Small Sea
			foreground.z_index = 1
			layer_switch = 8
			final_fences.visible = true
			final_fences.position.y = FENCE_OFFSET
			final_fences.z_index = 1
			final_fences.process_mode = Node.PROCESS_MODE_DISABLED
			defence_fences.visible = false
			#defence_fences.position.y = 0

	_set_cells_between(
		Vector2i(0, 9), Vector2i(4, 10), lose_tiles, layer_switch
	)


func _set_cells_between(
	start: Vector2i, end: Vector2i, terrain: Terrain, layer_switch: int = 9
) -> void:
	if not is_node_ready() and not Engine.is_editor_hint():
		await ready

	for y in range(end.y - start.y + 1):
		var use_layer: TileMapLayer
		var clear_layer: TileMapLayer
		if y + start.y <= layer_switch:
			use_layer = background_tile_map_layer
			clear_layer = foreground_tile_map_layer
		else:
			use_layer = foreground_tile_map_layer
			clear_layer = background_tile_map_layer
		for x in range(end.x - start.x + 1):
			var coords := Vector2i(x + start.x, y + start.y)
			use_layer.set_cell(coords, 0, ATLAS_MAP.get(terrain))
			clear_layer.set_cell(coords)
