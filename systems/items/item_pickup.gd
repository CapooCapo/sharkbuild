class_name ItemPickup
extends Node

@onready var world_item: WorldItem = get_parent()

var state: int = 0 # 0: dropping, 1: waiting, 2: flying
var target_player: Node2D
var _fly_tween: Tween

func _ready() -> void:
	# Start drop animation
	world_item.scale = Vector2(0.8, 0.8)
	var drop_tween = create_tween()
	drop_tween.set_parallel(true)
	
	var target_y = world_item.position.y + randf_range(6.0, 10.0)
	drop_tween.tween_property(world_item, "position:y", target_y, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	drop_tween.tween_property(world_item, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	drop_tween.chain().tween_interval(0.5)
	drop_tween.tween_callback(_start_flying)

func _start_flying() -> void:
	target_player = get_tree().get_first_node_in_group("player") as Node2D
	if not target_player:
		return
	
	state = 2
	var start_pos = world_item.global_position
	# Control point for curved flight (up and to the side slightly)
	var control_point = start_pos + Vector2(randf_range(-30, 30), randf_range(-60, -30))
	
	_fly_tween = create_tween()
	_fly_tween.tween_method(_fly_step.bind(start_pos, control_point), 0.0, 1.0, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	_fly_tween.tween_callback(_on_reached_player)

func _fly_step(t: float, start_pos: Vector2, control_point: Vector2) -> void:
	if not is_instance_valid(target_player):
		return
	var end_pos = target_player.global_position + Vector2(0, -16) # target center of player
	
	# Quadratic Bezier Curve
	var q0 = start_pos.lerp(control_point, t)
	var q1 = control_point.lerp(end_pos, t)
	world_item.global_position = q0.lerp(q1, t)

const DEBUG_LOOT: bool = true

func _on_reached_player() -> void:
	if is_instance_valid(target_player):
		_collect(target_player)

func _collect(interactor: Node) -> void:
	if not world_item.item_data:
		world_item.queue_free()
		return
		
	var inventory: Inventory = null
	for child in interactor.get_children():
		if child is Inventory:
			inventory = child
			break
			
	if not inventory:
		push_warning("ItemPickup: Interactor has no Inventory component.")
		world_item.queue_free()
		return
		
	if not world_item.pickup(inventory):
		if DEBUG_LOOT: print("[DEBUG_LOOT] Pickup failed: Inventory full.")
		# If inventory is full, drop it back down
		state = 1
		world_item.position.y += 10
	else:
		if DEBUG_LOOT: print("[DEBUG_LOOT] Pickup Collected.")
