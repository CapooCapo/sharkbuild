class_name TerrainData
extends RefCounted

## Dictionary mapping Vector2i coordinates to tile IDs
var tiles: Dictionary = {}
var size: Vector2i = Vector2i.ZERO

func set_tile(coord: Vector2i, tile_id: int) -> void:
	tiles[coord] = tile_id

func get_tile(coord: Vector2i) -> int:
	return tiles.get(coord, -1)
