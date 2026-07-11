extends SceneTree
func _init():
	var scene = load("res://scenes/village/village.tscn")
	var instance = scene.instantiate()
	root.add_child(instance)
	call_deferred("check_nav")
	
func check_nav():
	await root.get_tree().create_timer(1.0).timeout
	var maps = NavigationServer2D.get_maps()
	print("[NAV_DEBUG] Nav Maps: ", maps)
	if maps.size() > 0:
		print("[NAV_DEBUG] Regions in Map 0: ", NavigationServer2D.map_get_regions(maps[0]).size())
		print("[NAV_DEBUG] Map Active: ", NavigationServer2D.map_is_active(maps[0]))
	quit()
