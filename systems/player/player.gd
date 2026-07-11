class_name Player
extends CharacterBody2D

## Main player node. Integrates Movement and Interaction components.

@export var interactor: Interactor

func _ready() -> void:
	# Instantiate CharacterStats
	var stats: CharacterStats = CharacterStats.new()
	stats.name = "CharacterStats"
	var sm: PlayerStateMachine = $PlayerStateMachine
	stats.player_data = sm.player_data if sm else null
	add_child(stats)
	
	# Pass CharacterStats to Movement and Combat
	var movement: PlayerMovement = $PlayerMovement
	if movement:
		movement.character_stats = stats
		
	var cc: CombatController = CombatController.new()
	cc.name = "CombatController"
	cc.state_machine = $PlayerStateMachine
	cc.player_direction = $PlayerDirection
	cc.hit_box = $HitBox
	cc.character_stats = stats
	add_child(cc)
	
	# Configure HitBox
	var hit_box = $HitBox
	if hit_box and "damage_amount" in hit_box:
		hit_box.source_stats = stats
		hit_box.damage_amount = int(sm.player_data.attack_cost) if sm and sm.player_data else 10
	
	# Re-route animation signals to CombatController for hitbox
	var anim: PlayerAnimation = $PlayerAnimation
	if anim:
		# Connect to Combat Controller and Movement
		anim.attack_hit.connect(cc.on_attack_hit_start)
		anim.attack_end.connect(cc.on_attack_end)
		
		if movement:
			anim.roll_end.connect(movement.on_roll_end)
		
	# Instantiate PlayerHUD
	var hud: PlayerHUD = PlayerHUD.new()
	hud.name = "PlayerHUD"
	add_child(hud)
	hud.initialize(stats)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"): # Generic interact button (Space/Enter)
		if interactor:
			interactor.try_interact()
