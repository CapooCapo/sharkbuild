class_name CombatController
extends Node

@export var state_machine: PlayerStateMachine
@export var player_direction: PlayerDirection
@export var hit_box: Area2D

@export var character_stats: Node

func _process(_delta: float) -> void:
	if not state_machine:
		return
		
	var sm = state_machine
	var state = sm.current_state
	
	# Clean up HitBox if attack is interrupted
	if state != sm.State.ATTACK and hit_box:
		var col = hit_box.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if col and not col.disabled:
			_set_hitbox_active(false)
	
	# Handle input for combat
	if Input.is_action_just_pressed("attack"):
		var cost = 15.0 # default fallback
		if sm.player_data:
			cost = sm.player_data.attack_cost
			
		if not character_stats or character_stats.current_stamina >= cost:
			if sm.request_state(sm.State.ATTACK):
				if character_stats:
					character_stats.consume_stamina(cost)
					
	elif Input.is_action_pressed("guard"):
		sm.request_state(sm.State.GUARD)
	elif state == sm.State.GUARD:
		sm.force_state(sm.State.IDLE)
	
	# Update generic lock in PlayerDirection
	if player_direction:
		player_direction.lock_direction(sm.is_direction_locked())
		
func on_attack_hit_start() -> void:
	if hit_box and player_direction:
		var attack_range = 16.0
		if state_machine and state_machine.player_data and "attack_range" in state_machine.player_data:
			attack_range = state_machine.player_data.attack_range
		hit_box.position = player_direction.get_facing_vector() * attack_range
	_set_hitbox_active(true)

func on_attack_end() -> void:
	if hit_box:
		hit_box.position = Vector2.ZERO
	_set_hitbox_active(false)
	if state_machine:
		state_machine.force_state(state_machine.State.IDLE)

func _set_hitbox_active(active: bool) -> void:
	if not hit_box: return
	var col = hit_box.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if col:
		col.disabled = not active
