class_name PlayerStateMachine
extends Node

enum State { IDLE, WALK, RUN, ROLL, ATTACK, GUARD, HIT, DEAD }

@export var character_body: CharacterBody2D
@export var player_data: PlayerData

var current_state: State = State.IDLE

func request_state(new_state: State) -> bool:
	if current_state == State.DEAD:
		return false
		
	if new_state == State.ATTACK or new_state == State.ROLL or new_state == State.GUARD:
		if current_state in [State.IDLE, State.WALK, State.RUN]:
			current_state = new_state
			return true
		return false
		
	# For movement transitions
	if new_state in [State.IDLE, State.WALK, State.RUN]:
		if current_state in [State.IDLE, State.WALK, State.RUN]:
			current_state = new_state
			return true
		return false
		
	current_state = new_state
	return true

func force_state(new_state: State) -> void:
	if current_state != State.DEAD:
		current_state = new_state

func is_movement_locked() -> bool:
	return current_state in [State.ATTACK, State.ROLL, State.GUARD, State.HIT, State.DEAD]

func is_direction_locked() -> bool:
	return current_state in [State.ATTACK, State.ROLL, State.GUARD, State.HIT, State.DEAD]
