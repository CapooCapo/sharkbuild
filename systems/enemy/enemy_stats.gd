class_name EnemyStats
extends BaseStats

## Single source of truth for enemy HP and death state.
## Mirrors CharacterStats but stripped to enemy essentials.
## No mana, no stamina, no EXP progression.

@export var enemy_data: EnemyData

var exp_reward: int = 0
var invulnerable: bool = false

var _iframe_timer: float = 0.0

func _process(delta: float) -> void:
	super._process(delta)
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

func damage(amount: int, type: int = 0) -> void: # 0 is DamageType.Type.NORMAL
	if not alive or invulnerable:
		return
	
	# Trigger iframes
	if enemy_data and "iframe_duration" in enemy_data:
		invulnerable = true
		_iframe_timer = enemy_data.iframe_duration
	
	super.damage(amount, type)
