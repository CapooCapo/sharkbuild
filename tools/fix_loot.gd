@tool
extends SceneTree

func _init() -> void:
	var item = ItemData.new()
	item.name = "Gold Coin"
	item.icon = load("res://icon.svg") as Texture2D
	ResourceSaver.save(item, "res://data/items/gold_coin.tres")
	
	var entry = LootEntry.new()
	entry.item = item
	entry.drop_weight = 1.0
	
	var table = LootTable.new()
	table.entries.append(entry)
	ResourceSaver.save(table, "res://data/loot_tables/goblin_loot.tres")
	
	var enemy_data = load("res://data/enemy_data.tres") as EnemyData
	if enemy_data:
		enemy_data.loot_table = table
		ResourceSaver.save(enemy_data, "res://data/enemy_data.tres")
		
	print("Fix applied")
	quit()
