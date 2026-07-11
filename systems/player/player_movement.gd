class_name PlayerMovement
extends Node

@export var character_body: CharacterBody2D
@export var player_data: PlayerData
@export var state_machine: PlayerStateMachine
@export var player_direction: PlayerDirection
@export var character_stats: CharacterStats

var _roll_direction: Vector2 = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	if not character_body or not player_data or not state_machine or not player_direction:
		return
		
	var sm: PlayerStateMachine = state_machine
	var state: PlayerStateMachine.State = sm.current_state
	
	if sm.is_movement_locked():
		if state == sm.State.ROLL:
			character_body.velocity = _roll_direction * player_data.roll_speed
			character_body.move_and_slide()
		else:
			character_body.velocity = Vector2.ZERO
			character_body.move_and_slide()
		return
		
	# Process input requests
	if Input.is_action_just_pressed("roll"):
		if character_stats and character_stats.current_stamina >= player_data.roll_cost:
			if sm.request_state(sm.State.ROLL):
				character_stats.consume_stamina(player_data.roll_cost)
				var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
				if input_dir.length_squared() > 0.1:
					_roll_direction = input_dir.normalized()
				else:
					_roll_direction = player_direction.get_facing_vector()
				
				character_body.velocity = _roll_direction * player_data.roll_speed
				character_body.move_and_slide()
				return
	
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var is_moving: bool = input_dir.length_squared() > 0.1
	
	if is_moving:
		if Input.is_action_pressed("run") and character_stats and character_stats.current_stamina > 0.0:
			sm.request_state(sm.State.RUN)
		else:
			sm.request_state(sm.State.WALK)
	else:
		if state != sm.State.GUARD: # Guard requested by combat controller, dont overwrite if not moving
			sm.request_state(sm.State.IDLE)
			
	# Refresh state after requests
	state = sm.current_state
	var speed: float = player_data.walk_speed
	
	if state == sm.State.RUN:
		# Drain stamina
		if character_stats:
			if not character_stats.consume_stamina(player_data.run_stamina_cost * _delta):
				sm.request_state(sm.State.WALK)
				state = sm.State.WALK
		
		if state == sm.State.RUN:
			speed = player_data.run_speed
			
	if state == sm.State.GUARD:
		speed = player_data.walk_speed * player_data.guard_speed_multiplier
		
	character_body.velocity = input_dir * speed
	character_body.move_and_slide()

func on_roll_end() -> void:
	if state_machine:
		state_machine.force_state(state_machine.State.IDLE)
