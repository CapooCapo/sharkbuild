class_name EnemyStats
extends Node

## Single source of truth for enemy HP and death state.
## Mirrors CharacterStats but stripped to enemy essentials.
## No mana, no stamina, no EXP progression.

signal hp_changed(current: int, maximum: int)
signal damage_taken(amount: int, type: int)
signal healed(amount: int)
signal died()

@export var enemy_data: EnemyData

var current_hp: int = 0
var max_hp: int = 0
var exp_reward: int = 0
var alive: bool = true
var invulnerable: bool = false

var _iframe_timer: float = 0.0

func _process(delta: float) -> void:
	if _iframe_timer > 0.0:
		_iframe_timer -= delta
		if _iframe_timer <= 0.0:
			invulnerable = false

func _ready() -> void:
	if not enemy_data:
		return
	
	max_hp = enemy_data.max_hp
	current_hp = max_hp
	exp_reward = enemy_data.exp_reward
	alive = true
	invulnerable = false
	_iframe_timer = 0.0
	
	hp_changed.emit(current_hp, max_hp)

func damage(amount: int, type: int = DamageType.Type.NORMAL) -> void:
	if not alive or invulnerable:
		return
	
	# Trigger iframes
	if enemy_data and "iframe_duration" in enemy_data:
		invulnerable = true
		_iframe_timer = enemy_data.iframe_duration
	
	var actual_damage = mini(current_hp, amount)
	current_hp = maxi(current_hp - amount, 0)
	
	hp_changed.emit(current_hp, max_hp)
	damage_taken.emit(actual_damage, type)
	
	if current_hp <= 0:
		alive = false
		died.emit()

func heal(amount: int) -> void:
	if not alive:
		return
	
	var actual_heal = mini(max_hp - current_hp, amount)
	current_hp = mini(current_hp + amount, max_hp)
	
	hp_changed.emit(current_hp, max_hp)
	healed.emit(actual_heal)

func is_dead() -> bool:
	return not alive
