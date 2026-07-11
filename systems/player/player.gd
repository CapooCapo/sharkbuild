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
	
	# Instantiate DamageReceiver
	var dr: DamageReceiver = DamageReceiver.new()
	dr.name = "DamageReceiver"
	dr.hurt_box = $HurtBox
	dr.character_stats = stats
	dr.state_machine = $PlayerStateMachine
	add_child(dr)
	
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
		anim.hit_finished.connect(dr.on_hit_finished)
		
		if movement:
			anim.roll_end.connect(movement.on_roll_end)
		
	# Instantiate PlayerHUD
	var hud: PlayerHUD = PlayerHUD.new()
	hud.name = "PlayerHUD"
	add_child(hud)
	hud.initialize(stats)
	
	# Instantiate DamagePresenter
	var damage_presenter = DamagePresenter.new()
	damage_presenter.name = "DamagePresenter"
	damage_presenter.stats_node = stats
	damage_presenter.entity_node = self
	damage_presenter.damage_manager = get_tree().get_first_node_in_group("damage_manager")
	add_child(damage_presenter)
	
	# Instantiate Inventory
	var inventory = Inventory.new()
	inventory.name = "Inventory"
	add_child(inventory)
	
	# Instantiate GameMenu inside HUD (or directly on Player)
	var menu_scene = preload("res://ui/game_menu/game_menu.tscn")
	if menu_scene:
		var menu = menu_scene.instantiate() as GameMenu
		menu.inventory = inventory
		add_child(menu)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"): # Generic interact button (Space/Enter)
		if interactor:
			interactor.try_interact()
