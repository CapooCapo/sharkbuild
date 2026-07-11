class_name Enemy
extends CharacterBody2D

## Enemy composition root.
## Wires all enemy components together in _ready().
## Mirrors Player.gd architecture — no gameplay logic here.

@export var enemy_data: EnemyData

@onready var stats: EnemyStats = EnemyStats.new()

func _ready() -> void:
	# Instantiate EnemyStats
	stats.name = "EnemyStats"
	stats.enemy_data = enemy_data
	add_child(stats)
	
	stats.died.connect(_on_died)
	
	# Instantiate Presentation Components
	_setup_presentation()
	
	# Instantiate EnemyCombatController
	var cc: EnemyCombatController = EnemyCombatController.new()
	cc.name = "EnemyCombatController"
	cc.state_machine = $EnemyStateMachine
	cc.enemy_stats = stats
	cc.enemy_direction = $EnemyDirection
	cc.hurt_box = $HurtBox
	cc.hit_box = $HitBox
	cc.enemy_knockback = $EnemyKnockback
	add_child(cc)
	
	# Configure HitBox
	var hit_box = $HitBox
	if hit_box and "damage_amount" in hit_box:
		hit_box.source_stats = stats
		hit_box.damage_amount = enemy_data.attack_damage if enemy_data else 10
	
	# Connect animation signals to combat controller
	var anim: EnemyAnimation = $EnemyAnimation
	if anim:
		anim.attack_started.connect(cc.on_attack_started)
		anim.attack_hit.connect(cc.on_attack_hit)
		anim.attack_finished.connect(cc.on_attack_finished)
		anim.hit_finished.connect(cc.on_hit_finished)
		
		# On death animation finished, remove enemy from scene
		anim.death_finished.connect(_on_death_finished)

func _setup_presentation() -> void:
	# Health Bar
	var health_bar_ui = get_node_or_null("HealthBar") as ProgressBar
	if health_bar_ui:
		if enemy_data:
			health_bar_ui.max_value = enemy_data.max_hp
			health_bar_ui.value = enemy_data.max_hp
			
		var hb_comp = EnemyHealthBar.new()
		hb_comp.name = "EnemyHealthBar"
		hb_comp.enemy_stats = stats
		hb_comp.progress_bar = health_bar_ui
		add_child(hb_comp)
		
	# Damage Flash
	var sprite = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if sprite:
		var flash_comp = EnemyDamageFlash.new()
		flash_comp.name = "EnemyDamageFlash"
		flash_comp.enemy_stats = stats
		flash_comp.animated_sprite = sprite
		add_child(flash_comp)
		
	# Popup Spawner
	var popup_spawner = EnemyPopupSpawner.new()
	popup_spawner.name = "EnemyPopupSpawner"
	popup_spawner.enemy_stats = stats
	popup_spawner.spawn_position_node = self
	add_child(popup_spawner)
	
	# Damage Presenter
	var damage_presenter = DamagePresenter.new()
	damage_presenter.name = "DamagePresenter"
	damage_presenter.stats_node = stats
	damage_presenter.entity_node = self
	damage_presenter.damage_manager = get_tree().get_first_node_in_group("damage_manager")
	add_child(damage_presenter)
	
	# Loot Dropper
	var dropper = LootDropper.new()
	dropper.name = "LootDropper"
	dropper.enemy_stats = stats
	if enemy_data and enemy_data.loot_table:
		dropper.loot_table = enemy_data.loot_table
	add_child(dropper)
		
func _on_died() -> void:
	# Disable Collisions & Movement
	var col = get_node_or_null("CollisionShape2D") as CollisionShape2D
	if col:
		col.set_deferred("disabled", true)
		
	var hurt_box = get_node_or_null("HurtBox/CollisionShape2D") as CollisionShape2D
	if hurt_box:
		hurt_box.set_deferred("disabled", true)
		
	var hit_box = get_node_or_null("HitBox/CollisionShape2D") as CollisionShape2D
	if hit_box:
		hit_box.set_deferred("disabled", true)
	
	# Also disable sensor collision if possible
	var sensor = get_node_or_null("EnemySensor")
	if sensor:
		var sensor_col = sensor.get_node_or_null("CollisionShape2D")
		if sensor_col:
			sensor_col.set_deferred("disabled", true)
			
	var ai = get_node_or_null("EnemyAI")
	if ai:
		ai.set_process(false)
		ai.set_physics_process(false)
	
	velocity = Vector2.ZERO
	
	# Disable AI & State updates by killing processes
	set_physics_process(false)
	var cc = get_node_or_null("EnemyCombatController")
	if cc:
		cc.set_process(false)
		cc.set_physics_process(false)

func _on_death_finished() -> void:
	queue_free()
