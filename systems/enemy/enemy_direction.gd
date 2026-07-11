class_name EnemyDirection
extends Node

## Simplified direction tracker for enemies.
## Can track facing from velocity or face toward a target position.

enum Direction { RIGHT, LEFT, UP, DOWN }

@export var character_body: CharacterBody2D

var current_direction: Direction = Direction.LEFT
var is_locked: bool = false

func _process(_delta: float) -> void:
	if not character_body or is_locked:
		return
	
	var vel := character_body.velocity
	if vel.length_squared() > 0.1:
		if abs(vel.x) > abs(vel.y):
			current_direction = Direction.RIGHT if vel.x > 0 else Direction.LEFT
		else:
			current_direction = Direction.DOWN if vel.y > 0 else Direction.UP

func face_toward(target_pos: Vector2) -> void:
	if not character_body or is_locked:
		return
	
	var diff = target_pos - character_body.global_position
	if abs(diff.x) > abs(diff.y):
		current_direction = Direction.RIGHT if diff.x > 0 else Direction.LEFT
	else:
		current_direction = Direction.DOWN if diff.y > 0 else Direction.UP

func lock_direction(locked: bool) -> void:
	is_locked = locked

func get_facing_vector() -> Vector2:
	match current_direction:
		Direction.RIGHT: return Vector2.RIGHT
		Direction.LEFT: return Vector2.LEFT
		Direction.UP: return Vector2.UP
		Direction.DOWN: return Vector2.DOWN
	return Vector2.LEFT
