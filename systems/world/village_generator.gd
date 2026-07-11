class_name VillageGenerator
extends RefCounted

## Math-only Village Placement.

func generate_village_position(terrain_data: TerrainData, village_data: VillageData) -> Vector2:
	var center_x := terrain_data.size.x / 2
	var center_y := terrain_data.size.y / 2
	
	# Look for grass (1) near the center
	for offset_x in range(-5, 5):
		for offset_y in range(-5, 5):
			var check_pos := Vector2i(center_x + offset_x, center_y + offset_y)
			if terrain_data.get_tile(check_pos) == 1:
				# 16 is the standard tile size for Tiny Swords
				return Vector2(check_pos.x * 16.0 + 8.0, check_pos.y * 16.0 + 8.0)
				
	return Vector2(center_x * 16.0 + 8.0, center_y * 16.0 + 8.0)
