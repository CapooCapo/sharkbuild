@tool
extends SceneTree

func _init() -> void:
	var items = [
		{"name": "Gold Coin", "path": "res://assets/Tiny Swords (Free Pack)/Terrain/Resources/Gold/Gold Resource/Gold_Resource.png", "is_atlas": true, "size": 128},
		{"name": "Wood", "path": "res://assets/Tiny Swords (Free Pack)/Terrain/Resources/Wood/Wood Resource/Wood Resource.png", "is_atlas": true, "size": 128},
		{"name": "Stone", "path": "res://assets/Tiny Swords (Free Pack)/Terrain/Decorations/Rocks/Rock1.png", "is_atlas": false, "size": 64},
		{"name": "Iron Ore", "path": "res://assets/Tiny Swords (Free Pack)/Terrain/Decorations/Rocks/Rock2.png", "is_atlas": false, "size": 64},
		{"name": "Health Potion", "path": "res://assets/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_06.png", "is_atlas": false, "size": 64},
		{"name": "Mana Potion", "path": "res://assets/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_05.png", "is_atlas": false, "size": 64},
		{"name": "Sword", "path": "res://assets/Tiny Swords (Free Pack)/UI Elements/UI Elements/Swords/Swords.png", "is_atlas": true, "size": 64},
		{"name": "Shield", "path": "res://assets/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_11.png", "is_atlas": false, "size": 64},
		{"name": "Helmet", "path": "res://assets/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_12.png", "is_atlas": false, "size": 64}
	]
	
	for data in items:
		var tex = load(data["path"]) as Texture2D
		var final_tex: Texture2D
		
		if data["is_atlas"] and tex:
			var atlas = AtlasTexture.new()
			atlas.atlas = tex
			# Assume first frame is top-left
			var s = data["size"]
			# To crop the empty space, we can take a smaller region, e.g. center
			var region = Rect2(s/2 - 32, s/2 - 32, 64, 64) 
			# Actually let's just take 0,0,128,128
			atlas.region = Rect2(0, 0, s, s)
			final_tex = atlas
		else:
			final_tex = tex
			
		var item = ItemData.new()
		item.name = data["name"]
		item.icon = final_tex
		item.max_stack = 99
		
		var safe_name = data["name"].to_lower().replace(" ", "_")
		ResourceSaver.save(item, "res://data/items/" + safe_name + ".tres")
		print("Saved: " + safe_name + ".tres")
		
		# Update goblin_loot.tres with gold coin if it is Gold Coin
		if data["name"] == "Gold Coin":
			var table = load("res://data/loot_tables/goblin_loot.tres") as LootTable
			if table and table.entries.size() > 0:
				table.entries[0].item = item
				ResourceSaver.save(table, "res://data/loot_tables/goblin_loot.tres")
				
	quit()
