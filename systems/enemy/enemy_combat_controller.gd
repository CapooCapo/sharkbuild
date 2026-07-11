class_name EnemyCombatController
extends Node

## Owns enemy combat logic: hurtbox monitoring, hitbox activation,
## damage pipeline, death pipeline, and EXP award.
## Mirrors CombatController but for enemies.

@export var state_machine: EnemyStateMachine
@export var enemy_stats: EnemyStats
@export var enemy_direction: EnemyDirection
@export var hurt_box: Area2D
@export var hit_box: Area2D
@export var enemy_knockback: EnemyKnockback

## Reference to the player's CharacterStats for EXP award.
## Set by the Enemy composition root.
var player_stats: Node = null

var _exp_awarded: bool = false

func _ready() -> void:
	# Connect hurtbox to detect payloads
	if hurt_box and hurt_box.has_signal("hit_received"):
		hurt_box.hit_received.connect(_on_hit_received)
	
	# Connect died signal for death pipeline
	if enemy_stats:
		enemy_stats.died.connect(_on_died)

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

func _on_hit_received(payload: DamagePayload) -> void:
	if not enemy_stats or enemy_stats.is_dead() or enemy_stats.invulnerable:
		return
	
	# Apply damage
	enemy_stats.damage(payload.amount)
	
	# Apply knockback
	if enemy_knockback and payload.source:
		var source_pos = payload.source.get_parent().global_position
		var my_pos = get_parent().global_position
		var dir = (my_pos - source_pos).normalized()
		var force = 300.0
		if enemy_stats.enemy_data and "knockback_force" in enemy_stats.enemy_data:
			force = enemy_stats.enemy_data.knockback_force
		enemy_knockback.apply_knockback(dir * force)
	
	# Cache the player's CharacterStats for EXP award
	if not player_stats and payload.source:
		player_stats = payload.source
	
	# Play hit reaction if still alive
	if not enemy_stats.is_dead():
		if state_machine:
			state_machine.force_state(state_machine.State.STAGGER)

func _on_died() -> void:
	if state_machine:
		state_machine.force_state(state_machine.State.DEAD)
	
	# Disable all collision
	_disable_all_collision()
	
	# Award EXP exactly once
	if not _exp_awarded and player_stats and player_stats.has_method("add_exp"):
		player_stats.add_exp(enemy_stats.exp_reward)
		_exp_awarded = true

func on_attack_started() -> void:
	if enemy_direction:
		enemy_direction.lock_direction(true)

func on_attack_hit() -> void:
	if hit_box and enemy_direction:
		var attack_range = 16.0
		if enemy_stats and enemy_stats.enemy_data and "attack_range" in enemy_stats.enemy_data:
			attack_range = enemy_stats.enemy_data.attack_range
		hit_box.position = enemy_direction.get_facing_vector() * attack_range
	_set_hitbox_active(true)

func on_attack_finished() -> void:
	if enemy_direction:
		enemy_direction.lock_direction(false)
	if hit_box:
		hit_box.position = Vector2.ZERO
	_set_hitbox_active(false)
	if state_machine:
		state_machine.force_state(state_machine.State.RECOVERY)

func on_hit_finished() -> void:
	if state_machine and state_machine.current_state == state_machine.State.STAGGER:
		state_machine.force_state(state_machine.State.IDLE)

func _set_hitbox_active(active: bool) -> void:
	if not hit_box: return
	var col = hit_box.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if col:
		col.disabled = not active

func _disable_all_collision() -> void:
	# Disable hurtbox
	if hurt_box:
		var col = hurt_box.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if col:
			col.set_deferred("disabled", true)
	
	# Disable hitbox
	if hit_box:
		var col = hit_box.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if col:
			col.set_deferred("disabled", true)
	
	# Disable body collision
	var body = get_parent() as CharacterBody2D
	if body:
		var col = body.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if col:
			col.set_deferred("disabled", true)
