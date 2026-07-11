class_name EnemyStateMachine
extends Node

## Mirrors PlayerStateMachine with enemy-specific states.
## Future states (Patrol, Chase, Return, Skill) can be added
## without modifying existing transitions.

enum State { IDLE, ALERT, MOVE, ATTACK, RECOVERY, STAGGER, RETURN, DEAD }

var current_state: State = State.IDLE

func request_state(new_state: State) -> bool:
	if current_state == State.DEAD:
		return false
	
	if new_state == State.STAGGER:
		current_state = new_state
		return true
		
	# Cannot interrupt hit, stagger, or attack with movement-type states
	if new_state == State.ATTACK:
		if current_state in [State.IDLE, State.ALERT, State.MOVE]:
			current_state = new_state
			return true
		return false
		
	if new_state == State.RECOVERY:
		if current_state in [State.ATTACK]:
			current_state = new_state
			return true
		return false
		
	if new_state == State.RETURN:
		if current_state in [State.IDLE, State.ALERT, State.MOVE, State.RECOVERY, State.STAGGER]:
			current_state = new_state
			return true
		return false
		
	if new_state == State.MOVE:
		if current_state in [State.ALERT, State.MOVE, State.STAGGER, State.ATTACK, State.RECOVERY, State.RETURN]:
			current_state = new_state
			return true
		return false
	
	if new_state == State.ALERT:
		if current_state in [State.IDLE, State.MOVE, State.RECOVERY, State.STAGGER, State.RETURN]:
			current_state = new_state
			return true
		return false
		
	if new_state == State.IDLE:
		if current_state in [State.IDLE, State.ALERT, State.MOVE, State.RECOVERY, State.STAGGER, State.RETURN]:
			current_state = new_state
			return true
		return false
	
	current_state = new_state
	return true

func force_state(new_state: State) -> void:
	if current_state != State.DEAD or new_state == State.DEAD:
		current_state = new_state

func is_action_locked() -> bool:
	return current_state in [State.ATTACK, State.STAGGER, State.DEAD]
