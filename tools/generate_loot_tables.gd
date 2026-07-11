@tool
extends SceneTree

func _init() -> void:
	var table1 = LootTable.new()
	ResourceSaver.save(table1, "res://data/loot_tables/goblin_loot.tres")
	
	var table2 = LootTable.new()
	ResourceSaver.save(table2, "res://data/loot_tables/skeleton_loot.tres")
	
	var table3 = LootTable.new()
	ResourceSaver.save(table3, "res://data/loot_tables/wolf_loot.tres")
	
	print("Loot tables generated successfully.")
	quit()
