class_name NavigationGenerator
extends Node

## Independent logic to generate navigation mesh for the Region.
## For Godot 4.x TileMaps, Navigation is often baked into the tileset, 
## but this class can trigger the Region's bake process dynamically.

@export var navigation_region: NavigationRegion2D

func generate_navigation(terrain_data: TerrainData) -> void:
	if not navigation_region:
		push_warning("NavigationGenerator: No NavigationRegion2D assigned.")
		return
		
	# In a real scenario with dynamically drawn TileMapLayers inside a Region,
	# we call bake() to parse the tiles and create the polygon.
	navigation_region.bake_navigation_polygon()
	print("NavigationGenerator: Navigation baked.")
