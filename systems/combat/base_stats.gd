class_name BaseStats
extends Node

signal hp_changed(current: int, maximum: int)
signal damage_taken(amount: int, type: int)
signal healed(amount: int)
signal died()

@export var auto_heal_enabled: bool = true
@export var heal_delay: float = 4.0
@export var heal_interval: float = 0.5
@export var heal_amount: int = 1

var current_hp: int = 0
var max_hp: int = 0
var alive: bool = true

var _last_damage_time: int = 0
var _heal_timer: float = 0.0

func _process(delta: float) -> void:
	_process_auto_heal(delta)

func _process_auto_heal(delta: float) -> void:
	if not alive or not auto_heal_enabled or current_hp >= max_hp:
		return
		
	var time_since_damage = (Time.get_ticks_msec() - _last_damage_time) / 1000.0
	if time_since_damage >= heal_delay:
		_heal_timer += delta
		if _heal_timer >= heal_interval:
			_heal_timer -= heal_interval
			_apply_auto_heal()

func _apply_auto_heal() -> void:
	heal(heal_amount)

func damage(amount: int, type: int = 0) -> void:
	if not alive:
		return
		
	var actual_damage = mini(current_hp, amount)
	current_hp = maxi(current_hp - amount, 0)
	
	_last_damage_time = Time.get_ticks_msec()
	_heal_timer = 0.0
	
	hp_changed.emit(current_hp, max_hp)
	damage_taken.emit(actual_damage, type)
	
	if current_hp <= 0:
		alive = false
		died.emit()

func heal(amount: int) -> void:
	if not alive:
		return
		
	var actual_heal = mini(max_hp - current_hp, amount)
	if actual_heal <= 0: return
	
	current_hp += actual_heal
	
	hp_changed.emit(current_hp, max_hp)
	healed.emit(actual_heal)

func is_dead() -> bool:
	return not alive
