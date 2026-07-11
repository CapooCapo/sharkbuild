class_name DamageReceiver
extends Node

@export var hurt_box: Area2D
@export var character_stats: CharacterStats
@export var state_machine: PlayerStateMachine

var _is_invulnerable: bool = false

func _ready() -> void:
	if hurt_box and hurt_box.has_signal("hit_received"):
		hurt_box.hit_received.connect(_on_hit_received)

func _on_hit_received(payload: DamagePayload) -> void:
	if not character_stats or character_stats.is_dead() or _is_invulnerable:
		return
		
	character_stats.damage(payload.amount)
	
	if not character_stats.is_dead() and state_machine:
		state_machine.force_state(state_machine.State.HIT)
		
	# Simple invulnerability to prevent multiple hits from one swing
	_is_invulnerable = true
	get_tree().create_timer(0.3).timeout.connect(func(): _is_invulnerable = false)
	
func on_hit_finished() -> void:
	if state_machine and state_machine.current_state == state_machine.State.HIT:
		state_machine.force_state(state_machine.State.IDLE)
