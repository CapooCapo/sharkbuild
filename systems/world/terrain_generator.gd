class_name TerrainGenerator
extends RefCounted

## Math-only Terrain Generator.

func generate(world_data: WorldData) -> TerrainData:
	var data := TerrainData.new()
	data.size = world_data.size
	
	var noise := FastNoiseLite.new()
	noise.seed = world_data.seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.05
	
	for x in range(world_data.size.x):
		for y in range(world_data.size.y):
			var val := noise.get_noise_2d(float(x), float(y))
			var coord := Vector2i(x, y)
			
			# Basic tile distribution for testing
			# 0 = Water, 1 = Grass, 2 = Dirt
			if val < -0.2:
				data.set_tile(coord, 0)
			elif val < 0.3:
				data.set_tile(coord, 1)
			else:
				data.set_tile(coord, 2)
				
	return data
