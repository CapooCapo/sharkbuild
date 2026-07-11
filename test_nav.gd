extends Node

func _ready() -> void:
	call_deferred("check_nav")
	
func check_nav() -> void:
	var maps = NavigationServer2D.get_maps()
	print("Nav Maps: ", maps)
	if maps.size() > 0:
		print("Regions in Map 0: ", NavigationServer2D.map_get_regions(maps[0]).size())
		print("Map Active: ", NavigationServer2D.map_is_active(maps[0]))
	get_tree().quit()
