class_name PlayerDirection
extends Node

## Tracks the current facing direction of the player.
## Updates based on the character body's velocity without duplicating input logic.

enum Direction {
	RIGHT,
	LEFT,
	UP,
	DOWN
}

@export var character_body: CharacterBody2D

var current_direction: Direction = Direction.RIGHT
var is_locked: bool = false

func _process(_delta: float) -> void:
	if not character_body:
		return
		
	if is_locked:
		return
		
	var vel := character_body.velocity
	if vel.length_squared() > 0.1:
		if abs(vel.x) > abs(vel.y):
			if vel.x > 0:
				current_direction = Direction.RIGHT
			else:
				current_direction = Direction.LEFT
		else:
			if vel.y > 0:
				current_direction = Direction.DOWN
			else:
				current_direction = Direction.UP

func lock_direction(locked: bool) -> void:
	is_locked = locked

func get_facing_vector() -> Vector2:
	match current_direction:
		Direction.RIGHT: return Vector2.RIGHT
		Direction.LEFT: return Vector2.LEFT
		Direction.UP: return Vector2.UP
		Direction.DOWN: return Vector2.DOWN
	return Vector2.RIGHT
