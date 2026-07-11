class_name TerrainRenderer
extends Node

## Draws TerrainData onto TileMapLayers.

@export var ground_layer: TileMapLayer
@export var road_layer: TileMapLayer
@export var object_layer: TileMapLayer
@export var decoration_layer: TileMapLayer

const TILE_WATER = Vector2i(0, 0)
const TILE_GRASS = Vector2i(1, 0)
const TILE_DIRT = Vector2i(2, 0)

func render(data: TerrainData) -> void:
	if not ground_layer:
		push_error("TerrainRenderer: Missing layers.")
		return
		
	ground_layer.clear()
	
	for coord in data.tiles.keys():
		var type = data.get_tile(coord)
		var atlas_coord: Vector2i
		
		match type:
			0: atlas_coord = TILE_WATER
			1: atlas_coord = TILE_GRASS
			2: atlas_coord = TILE_DIRT
			_: continue
			
		# Drawing strictly to GroundLayer for now.
		# Objects and Decorations can be painted here in the future based on data.
		ground_layer.set_cell(coord, 0, atlas_coord)
		

