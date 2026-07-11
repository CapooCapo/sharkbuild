class_name EnemyData
extends Resource

@export_group("Combat")
@export var max_hp: int = 30
@export var attack_damage: int = 10
@export var attack_duration: float = 0.4
@export var attack_range: float = 16.0
@export var attack_cooldown: float = 1.0
@export var attack_windup: float = 0.2
@export var attack_recovery: float = 0.2
@export var attack_hit_duration: float = 0.2
@export var iframe_duration: float = 0.2
@export var knockback_force: float = 300.0

@export_group("Movement")
@export var move_speed: float = 80.0

@export_group("Rewards")
@export var exp_reward: int = 25

@export_group("AI")
@export var detection_radius: float = 160.0
@export var chase_radius: float = 160.0
@export var lose_target_radius: float = 220.0
@export var max_chase_distance: float = 400.0
@export var aggro_timeout: float = 3.0
