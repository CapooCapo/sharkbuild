class_name LootDropper
extends Node

@export var loot_table: LootTable
@export var enemy_stats: EnemyStats
@export var drop_chance: float = 1.0 # 0.0 to 1.0
@export var world_item_scene: PackedScene = preload("res://scenes/items/world_item.tscn")

func _ready() -> void:
	if enemy_stats:
		enemy_stats.died.connect(_on_enemy_died)

const DEBUG_LOOT: bool = true
var _loot_spawned: bool = false

func _on_enemy_died() -> void:
	if _loot_spawned:
		return
	_loot_spawned = true
		
	if not loot_table or not world_item_scene:
		return
		
	if not DEBUG_LOOT and randf() > drop_chance:
		return
		
	var results = loot_table.roll_multiple(1) # Default to 1 roll for now, could be dynamic
	
	if DEBUG_LOOT and results.is_empty() and loot_table.entries.size() > 0:
		var first_entry = loot_table.entries[0]
		if first_entry and first_entry.item:
			results.append({"item": first_entry.item, "amount": first_entry.get_amount()})
	
	for res in results:
		if res.is_empty():
			continue
			
		var item_data = res["item"] as ItemData
		var amount = res["amount"] as int
		
		var world_item = world_item_scene.instantiate() as WorldItem
		world_item.initialize(item_data, amount)
		
		var entity = owner as Node2D
		var spawn_pos = Vector2.ZERO
		if entity:
			var offset = Vector2(randf_range(-8.0, 8.0), randf_range(-8.0, 8.0)) if results.size() > 1 else Vector2.ZERO
			spawn_pos = entity.global_position + offset
			
		# Add to the main scene tree
		var current_scene = get_tree().current_scene
		if current_scene:
			world_item.global_position = spawn_pos
			current_scene.call_deferred("add_child", world_item)
			if DEBUG_LOOT:
				print("--------------------------------\nEnemy Position:\n", entity.global_position if entity else Vector2.ZERO, "\nSpawn Position:\n", spawn_pos, "\nItem:\n", item_data.name, "\nIcon:\n", item_data.icon.resource_path if item_data.icon else "NULL", "\n--------------------------------")
				if not item_data.icon:
					print("[ERROR]\nItemData icon is NULL")
