class_name EnemyAI
extends Node2D

@export var sensor: EnemySensor
@export var state_machine: EnemyStateMachine
@export var enemy_direction: EnemyDirection
@export var movement: EnemyMovement
@export var enemy_data: EnemyData
@export var cooldown: EnemyCooldown

var _recovery_timer: float = 0.0
var _aggro_timer: float = 0.0
var _previous_state: int = -1

func _ready() -> void:
	if not sensor or not state_machine or not enemy_direction or not movement or not enemy_data or not cooldown:
		push_warning("EnemyAI is missing references")
		return
		
	if enemy_data and "move_speed" in enemy_data:
		movement.set_speed(enemy_data.move_speed)

func _process(delta: float) -> void:
	if not state_machine or not sensor or not enemy_direction or not movement or not enemy_data or not cooldown: return
	
	if OS.is_debug_build():
		queue_redraw()
		
	if state_machine.current_state == state_machine.State.DEAD:
		movement.stop()
		return
		
	if state_machine.current_state == state_machine.State.ATTACK or state_machine.current_state == state_machine.State.STAGGER:
		movement.stop()
		_previous_state = state_machine.current_state
		return
		
	if state_machine.current_state == state_machine.State.RECOVERY:
		movement.stop()
		if _previous_state == state_machine.State.ATTACK:
			_recovery_timer = enemy_data.attack_recovery
			cooldown.start(enemy_data.attack_cooldown)
			_previous_state = state_machine.current_state
		
		_recovery_timer -= delta
		if _recovery_timer <= 0.0:
			if sensor.has_target():
				state_machine.request_state(state_machine.State.MOVE)
			else:
				state_machine.request_state(state_machine.State.RETURN)
		return
		
	if state_machine.current_state == state_machine.State.RETURN:
		if movement.spawn_position.distance_to(movement.character_body.global_position) < 5.0:
			movement.stop()
			state_machine.request_state(state_machine.State.IDLE)
		else:
			enemy_direction.face_toward(movement.spawn_position)
			movement.move_towards(movement.spawn_position)
		_previous_state = state_machine.current_state
		return
		
	# Continuous Combat Evaluation (IDLE / ALERT / MOVE)
	_previous_state = state_machine.current_state
	
	# Leash check
	if movement.spawn_position.distance_to(movement.character_body.global_position) > enemy_data.max_chase_distance:
		sensor.clear_target()
		state_machine.request_state(state_machine.State.RETURN)
		return
		
	if not sensor.has_target():
		_aggro_timer -= delta
		if _aggro_timer <= 0.0:
			movement.stop()
			if state_machine.current_state != state_machine.State.IDLE:
				state_machine.request_state(state_machine.State.RETURN)
		else:
			movement.stop()
		return
	else:
		_aggro_timer = enemy_data.aggro_timeout
		
	var dist = sensor.get_distance_to_target()
	var target_pos = sensor.get_target_position()
	
	if dist > enemy_data.lose_target_radius:
		sensor.clear_target()
		movement.stop()
		state_machine.request_state(state_machine.State.RETURN)
		return
		
	if dist > enemy_data.attack_range:
		enemy_direction.face_toward(target_pos)
		movement.move_towards(target_pos)
		state_machine.request_state(state_machine.State.MOVE)
	else:
		movement.stop()
		enemy_direction.face_toward(target_pos)
		if cooldown.is_ready():
			state_machine.request_state(state_machine.State.ATTACK)
		else:
			state_machine.request_state(state_machine.State.ALERT)

func _draw() -> void:
	if OS.is_debug_build() and enemy_data and state_machine and cooldown:
		# Draw Attack Radius
		draw_circle(Vector2.ZERO, enemy_data.attack_range, Color(1, 0, 0, 0.2))
		# Draw Lose Target Radius
		draw_circle(Vector2.ZERO, enemy_data.lose_target_radius, Color(0, 0, 1, 0.1))
		
		# Draw State and Cooldown
		var state_name = state_machine.State.keys()[state_machine.current_state]
		var text = state_name
		if not cooldown.is_ready():
			text += " (CD: %.1f)" % cooldown.remaining_time()
		if state_machine.current_state == state_machine.State.RECOVERY:
			text += " (Rec: %.1f)" % maxf(0.0, _recovery_timer)
			
		draw_string(ThemeDB.fallback_font, Vector2(-20, -20), text, HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color.YELLOW)
		
		# Draw Target Line
		if sensor and sensor.has_target() and state_machine.current_state == state_machine.State.MOVE:
			var local_pos = to_local(sensor.get_target_position())
			draw_line(Vector2.ZERO, local_pos, Color.YELLOW, 2.0)
