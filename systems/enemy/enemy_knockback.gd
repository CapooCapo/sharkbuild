class_name EnemyKnockback
extends Node

## Applies temporary physics impulses to the Enemy.
## Handles the decay of the knockback force over time.

@export var character_body: CharacterBody2D

var _force: Vector2 = Vector2.ZERO
var _decay_rate: float = 1200.0

func apply_knockback(force: Vector2) -> void:
	_force = force

func is_active() -> bool:
	return _force.length_squared() > 10.0

func _physics_process(delta: float) -> void:
	if not character_body:
		return
		
	if is_active():
		character_body.velocity = _force
		character_body.move_and_slide()
		_force = _force.move_toward(Vector2.ZERO, _decay_rate * delta)
