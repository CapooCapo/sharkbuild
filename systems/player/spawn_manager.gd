class_name SpawnManager
extends Node

signal player_spawned(player_node: Node2D)

@export var characters_layer: Node2D
@export var player_scene: PackedScene
@export var player_data: PlayerData

func on_village_generated(spawn_pos: Vector2) -> void:
	if not characters_layer or not player_scene:
		push_error("SpawnManager: Missing references.")
		return
		
	var player_instance := player_scene.instantiate() as Node2D
	if player_instance:
		player_instance.position = spawn_pos
		
		# Inject data if the scene has a player_movement node configured
		var mov = player_instance.get_node_or_null("PlayerMovement")
		if mov and "player_data" in mov:
			mov.player_data = player_data
			
		characters_layer.add_child(player_instance)
		print("SpawnManager: Player spawned at %s" % spawn_pos)
		player_spawned.emit(player_instance)
