class_name CharacterStats
extends Node

signal hp_changed(current: int, max: int)
signal mana_changed(current: int, max: int)
signal stamina_changed(current: float, max: float)
signal exp_changed(current: int, required: int)
signal level_changed(current: int)
signal player_dead
signal damage_taken(amount: int, type: int)

@export var player_data: PlayerData

var current_hp: int = 0
var current_mana: int = 0
var current_stamina: float = 0.0
var current_exp: int = 0
var current_level: int = 1

var _stamina_regen_timer: float = 0.0

func _ready() -> void:
	if not player_data:
		return
		
	current_hp = player_data.max_hp
	current_mana = player_data.max_mana
	current_stamina = player_data.max_stamina
	current_exp = player_data.starting_exp
	current_level = player_data.starting_level
	
	_emit_all_signals()

func _process(delta: float) -> void:
	if not player_data or is_dead():
		return
		
	if _stamina_regen_timer > 0.0:
		_stamina_regen_timer -= delta
		return
		
	if current_stamina < player_data.max_stamina:
		current_stamina = clampf(current_stamina + (player_data.stamina_regeneration * delta), 0.0, player_data.max_stamina)
		stamina_changed.emit(current_stamina, player_data.max_stamina)

func consume_stamina(amount: float) -> bool:
	if current_stamina >= amount:
		current_stamina -= amount
		_stamina_regen_timer = 1.0 # 1 second delay
		stamina_changed.emit(current_stamina, player_data.max_stamina)
		return true
	return false

func consume_mana(amount: int) -> bool:
	if is_dead(): return false
	if current_mana >= amount:
		current_mana -= amount
		mana_changed.emit(current_mana, player_data.max_mana)
		return true
	return false

func restore_mana(amount: int) -> void:
	if is_dead(): return
	current_mana = mini(current_mana + amount, player_data.max_mana)
	mana_changed.emit(current_mana, player_data.max_mana)

func heal(amount: int) -> void:
	if is_dead(): return
	current_hp = mini(current_hp + amount, player_data.max_hp)
	hp_changed.emit(current_hp, player_data.max_hp)

func damage(amount: int, type: int = DamageType.Type.NORMAL) -> void:
	if is_dead(): return
	var actual_damage = mini(current_hp, amount)
	current_hp = maxi(current_hp - amount, 0)
	hp_changed.emit(current_hp, player_data.max_hp)
	damage_taken.emit(actual_damage, type)
	if is_dead():
		player_dead.emit()

func full_heal() -> void:
	if is_dead(): return
	heal(player_data.max_hp)

func is_dead() -> bool:
	return current_hp <= 0

func add_exp(amount: int) -> void:
	if is_dead(): return
	current_exp += amount
	exp_changed.emit(current_exp, required_exp())
	
	while current_exp >= required_exp():
		level_up()

func level_up() -> void:
	current_exp -= required_exp()
	current_level += 1
	
	# Increase stats (simple scaling logic for demonstration)
	player_data.max_hp += 10
	player_data.max_mana += 5
	player_data.max_stamina += 10.0
	
	full_heal()
	current_mana = player_data.max_mana
	current_stamina = player_data.max_stamina
	
	level_changed.emit(current_level)
	hp_changed.emit(current_hp, player_data.max_hp)
	stamina_changed.emit(current_stamina, player_data.max_stamina)
	exp_changed.emit(current_exp, required_exp())

func required_exp() -> int:
	return player_data.exp_curve_base * current_level

func _emit_all_signals() -> void:
	hp_changed.emit(current_hp, player_data.max_hp)
	mana_changed.emit(current_mana, player_data.max_mana)
	stamina_changed.emit(current_stamina, player_data.max_stamina)
	exp_changed.emit(current_exp, required_exp())
	level_changed.emit(current_level)
