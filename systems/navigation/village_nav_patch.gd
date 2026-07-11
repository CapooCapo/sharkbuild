extends NavigationRegion2D

func _ready() -> void:
	# Programmatically generate a large generic navigation polygon
	# to ensure the NavigationServer2D activates the map.
	var poly = NavigationPolygon.new()
	var outline = PackedVector2Array([
		Vector2(-10000, -10000), Vector2(10000, -10000), 
		Vector2(10000, 10000), Vector2(-10000, 10000)
	])
	poly.add_outline(outline)
	poly.make_polygons_from_outlines()
	self.navigation_polygon = poly
	
	# Bake dynamically allowing collision obstacles to carve out navmesh
	bake_navigation_polygon()
