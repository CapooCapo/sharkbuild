class_name EnemyAnimation
extends Node2D

## Presentation-only animation controller for enemies.
## Mirrors PlayerAnimation: loads spritesheets, builds AnimationPlayer,
## emits animation events via method tracks.
## Never owns gameplay logic.

@export var character_body: CharacterBody2D
@export var animated_sprite: AnimatedSprite2D
@export var enemy_direction: EnemyDirection
@export var state_machine: EnemyStateMachine

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

const ANIM_DIR = "res://assets/Tiny Swords (Free Pack)/Units/Red Units/Warrior/"

signal attack_started
signal attack_hit
signal attack_finished
signal hit_started
signal hit_finished
signal death_started
signal death_finished
signal idle_started
signal walk_started

var _animation_map: Dictionary = {}

func _ready() -> void:
	if not animated_sprite:
		return
	
	# Automatically discover animation assets and create SpriteFrames
	var frames = SpriteFrames.new()
	var dir = DirAccess.open(ANIM_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".png") and not file_name.ends_with(".import"):
				_add_animation_to_frames(frames, file_name)
			file_name = dir.get_next()
			
	animated_sprite.sprite_frames = frames
	
	_setup_animation_player()
	_setup_animation_map()
	animated_sprite.play("Warrior_Idle")

func _setup_animation_map() -> void:
	if not state_machine: return
	var sm = state_machine
	_animation_map = {
		sm.State.IDLE: "Idle",
		sm.State.ALERT: "Alert",
		sm.State.MOVE: "Run",
		sm.State.ATTACK: "Attack",
		sm.State.RECOVERY: "Alert",
		sm.State.STAGGER: "Hit",
		sm.State.RETURN: "Run",
		sm.State.DEAD: "Death"
	}

func _setup_animation_player() -> void:
	if not animation_player: return
	
	var anim_lib = AnimationLibrary.new()
	
	# Idle
	var anim_idle = Animation.new()
	anim_idle.length = 0.6
	anim_idle.loop_mode = Animation.LOOP_LINEAR
	_add_sprite_animation_track(anim_idle, "Warrior_Idle")
	anim_lib.add_animation("Idle", anim_idle)
	
	# Attack
	var anim_attack = Animation.new()
	anim_attack.length = 0.4
	_add_sprite_animation_track(anim_attack, "Warrior_Attack1")
	_add_method_track(anim_attack, 0.0, "emit_attack_started", [])
	_add_method_track(anim_attack, 0.2, "emit_attack_hit", [])
	_add_method_track(anim_attack, 0.4, "emit_attack_finished", [])
	anim_lib.add_animation("Attack", anim_attack)
	
	# Hit (reuse Idle spritesheet with short duration for flinch)
	var anim_hit = Animation.new()
	anim_hit.length = 0.3
	_add_sprite_animation_track(anim_hit, "Warrior_Idle")
	_add_method_track(anim_hit, 0.3, "emit_hit_finished", [])
	anim_lib.add_animation("Hit", anim_hit)
	
	# Death (reuse Idle spritesheet, fade out via modulate)
	var anim_death = Animation.new()
	anim_death.length = 0.6
	_add_sprite_animation_track(anim_death, "Warrior_Idle")
	# Fade out track
	var fade_track = anim_death.add_track(Animation.TYPE_VALUE)
	anim_death.track_set_path(fade_track, NodePath("AnimatedSprite2D:modulate"))
	anim_death.track_insert_key(fade_track, 0.0, Color(1, 0.3, 0.3, 1.0)) # Flash red
	anim_death.track_insert_key(fade_track, 0.3, Color(1, 0.3, 0.3, 0.5))
	anim_death.track_insert_key(fade_track, 0.6, Color(1, 1, 1, 0.0)) # Fade out
	_add_method_track(anim_death, 0.6, "emit_death_finished", [])
	anim_lib.add_animation("Death", anim_death)
	
	animation_player.add_animation_library("", anim_lib)
	animation_player.play("Idle")

func _add_sprite_animation_track(anim: Animation, sprite_anim: String) -> void:
	var track_idx = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track_idx, NodePath("AnimatedSprite2D:animation"))
	anim.track_insert_key(track_idx, 0.0, sprite_anim)

func _add_method_track(anim: Animation, time: float, method: String, args: Array) -> void:
	var track_idx = -1
	for i in range(anim.get_track_count()):
		if anim.track_get_type(i) == Animation.TYPE_METHOD and anim.track_get_path(i) == NodePath("EnemyAnimation"):
			track_idx = i
			break
	if track_idx == -1:
		track_idx = anim.add_track(Animation.TYPE_METHOD)
		anim.track_set_path(track_idx, NodePath("EnemyAnimation"))
		
	anim.track_insert_key(track_idx, time, {"method": method, "args": args})

func _add_animation_to_frames(frames: SpriteFrames, file_name: String) -> void:
	var path = ANIM_DIR + file_name
	var tex: Texture2D = load(path)
	if not tex: return
	
	var anim_name = file_name.get_basename()
	frames.add_animation(anim_name)
	frames.set_animation_loop(anim_name, true)
	
	if "Attack" in anim_name:
		frames.set_animation_speed(anim_name, 15.0)
	else:
		frames.set_animation_speed(anim_name, 10.0)
	
	var w = tex.get_width()
	var h = tex.get_height()
	var frame_width = 192
	var frame_count = w / frame_width
	
	for i in range(frame_count):
		var atlas = AtlasTexture.new()
		atlas.atlas = tex
		atlas.region = Rect2(i * frame_width, 0, frame_width, h)
		frames.add_frame(anim_name, atlas)

func _process(_delta: float) -> void:
	if not character_body or not animated_sprite or not enemy_direction or not state_machine:
		return
		
	var sm = state_machine
	var state = sm.current_state
	
	var anim_name = _animation_map.get(state, "Idle")
	play(anim_name)
		
	# Flip sprite based on direction
	if enemy_direction.current_direction == EnemyDirection.Direction.LEFT:
		animated_sprite.flip_h = true
	elif enemy_direction.current_direction == EnemyDirection.Direction.RIGHT:
		animated_sprite.flip_h = false
		
	if OS.is_debug_build():
		queue_redraw()

func play(anim_name: String) -> void:
	if not animation_player: return
	
	if animation_player.current_animation == "Death":
		return
		
	# Do not interrupt Attack or Hit mid-play unless it's a stronger interrupt
	# Hit interrupts Attack, Death interrupts everything (handled above)
	if animation_player.current_animation == "Hit" and anim_name != "Death" and animation_player.is_playing():
		return
	if animation_player.current_animation == "Attack" and anim_name not in ["Hit", "Death"] and animation_player.is_playing():
		return
		
	if not animation_player.has_animation(anim_name):
		# Fallback logic for missing Attack animation
		if anim_name == "Attack" and not get_meta("fast_forwarding", false):
			set_meta("fast_forwarding", true)
			if OS.is_debug_build():
				push_warning("Enemy Attack animation missing! Fast-forwarding attack.")
			call_deferred("emit_attack_started")
			call_deferred("emit_attack_hit")
			call_deferred("emit_attack_finished")
		anim_name = "Idle"
		
	if animation_player.current_animation == anim_name:
		return
		
	animation_player.play(anim_name)
	
	if anim_name == "Idle": idle_started.emit()
	if anim_name == "Run": walk_started.emit()

func _draw() -> void:
	if OS.is_debug_build() and animation_player:
		var text = "Anim: " + str(animation_player.current_animation)
		draw_string(ThemeDB.fallback_font, Vector2(-20, -35), text, HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color.GREEN)

# Explicit signal emitters for AnimationPlayer Method Tracks
func emit_attack_started() -> void: attack_started.emit()
func emit_attack_hit() -> void: attack_hit.emit()
func emit_attack_finished() -> void: 
	attack_finished.emit()
	set_meta("fast_forwarding", false)
func emit_hit_finished() -> void: hit_finished.emit()
func emit_death_finished() -> void: death_finished.emit()
