extends SceneTree

func _init() -> void:
	print("Injecting PlayerStateMachine...")
	var p_scene = load("res://scenes/player/player.tscn") as PackedScene
	if not p_scene:
		quit()
		return
		
	var p_node = p_scene.instantiate() as CharacterBody2D
	
	# Add StateMachine
	var sm_node = Node.new()
	sm_node.name = "PlayerStateMachine"
	var sm_script = load("res://systems/player/player_state_machine.gd")
	sm_node.set_script(sm_script)
	sm_node.character_body = p_node
	sm_node.player_data = load("res://data/player_data.tres")
	var hit_box = p_node.get_node_or_null("HitBox")
	sm_node.hit_box = hit_box
	p_node.add_child(sm_node)
	sm_node.owner = p_node
	
	# Update Movement
	var mov_node = p_node.get_node_or_null("PlayerMovement")
	if mov_node:
		mov_node.state_machine = sm_node
		
	# Update Animation
	var anim_node = p_node.get_node_or_null("PlayerAnimation")
	if anim_node:
		anim_node.state_machine = sm_node
		
	p_scene.pack(p_node)
	ResourceSaver.save(p_scene, "res://scenes/player/player.tscn")
	print("player.tscn updated with StateMachine.")
	quit()
