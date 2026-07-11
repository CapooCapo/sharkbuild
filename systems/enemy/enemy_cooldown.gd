class_name EnemyCooldown
extends Node

## Dedicated component to own combat cooldown timing for the enemy.
## Prevents the enemy from spamming attacks continuously.

var _timer: float = 0.0

func _process(delta: float) -> void:
	if _timer > 0.0:
		_timer -= delta

func is_ready() -> bool:
	return _timer <= 0.0

func start(duration: float) -> void:
	_timer = duration

func reset() -> void:
	_timer = 0.0

func remaining_time() -> float:
	return maxf(0.0, _timer)
