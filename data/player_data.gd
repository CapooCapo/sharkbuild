class_name PlayerData
extends Resource

@export var walk_speed: float = 200.0
@export var run_speed: float = 350.0
@export var roll_speed: float = 500.0
@export var roll_duration: float = 0.4
@export var attack_duration: float = 0.4

@export var guard_speed_multiplier: float = 0.25
@export var guard_turn_speed: float = 1.0
@export var guard_enabled: bool = true

@export_group("RPG Stats")
@export var max_hp: int = 100
@export var max_mana: int = 50
@export var max_stamina: float = 100.0
@export var stamina_regeneration: float = 15.0 # Per second

@export var roll_cost: float = 25.0
@export var attack_cost: float = 15.0
@export var attack_range: float = 16.0
@export var run_stamina_cost: float = 20.0 # Per second

@export_group("Progression")
@export var exp_curve_base: int = 100
@export var starting_level: int = 1
@export var starting_exp: int = 0
