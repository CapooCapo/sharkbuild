class_name WorldManager
extends Node

signal village_generated(spawn_pos: Vector2)

@export var world_data: WorldData
@export var village_data: VillageData
@export var terrain_renderer: TerrainRenderer
@export var navigation_generator: NavigationGenerator

func _ready() -> void:
	if not world_data or not village_data or not terrain_renderer:
		push_error("WorldManager: Missing dependencies.")
		return
		
	# Generation Phase
	var terrain_gen := TerrainGenerator.new()
	var terrain_data := terrain_gen.generate(world_data)
	
	# Rendering Phase
	terrain_renderer.render(terrain_data)
	
	# Navigation Phase
	if navigation_generator:
		navigation_generator.generate_navigation(terrain_data)
	
	# Village Phase
	var village_gen := VillageGenerator.new()
	var spawn_pos := village_gen.generate_village_position(terrain_data, village_data)
	

	village_generated.emit(spawn_pos)
