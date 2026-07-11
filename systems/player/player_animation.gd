class_name PlayerAnimation
extends Node

@export var character_body: CharacterBody2D
@export var animated_sprite: AnimatedSprite2D
@export var player_direction: Node
@export var state_machine: PlayerStateMachine

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

const ANIM_DIR = "res://assets/Tiny Swords (Free Pack)/Units/Blue Units/Warrior/"

signal attack_start
signal attack_hit
signal attack_end
signal roll_start
signal roll_end
signal footstep
signal guard_start
signal guard_hold
signal guard_end
signal perfect_block_window_open
signal perfect_block_window_close

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
	animated_sprite.play("Warrior_Idle")

func _setup_animation_player() -> void:
	if not animation_player: return
	
	var anim_lib = AnimationLibrary.new()
	
	# Idle
	var anim_idle = Animation.new()
	anim_idle.length = 0.6
	anim_idle.loop_mode = Animation.LOOP_LINEAR
	_add_sprite_animation_track(anim_idle, "Warrior_Idle")
	anim_lib.add_animation("Idle", anim_idle)
	
	# Walk
	var anim_walk = Animation.new()
	anim_walk.length = 0.6
	anim_walk.loop_mode = Animation.LOOP_LINEAR
	_add_sprite_animation_track(anim_walk, "Warrior_Run") # Using run as placeholder if walk missing
	_add_method_track(anim_walk, 0.3, "emit_footstep", [])
	anim_lib.add_animation("Walk", anim_walk)
	
	# Run
	var anim_run = Animation.new()
	anim_run.length = 0.6
	anim_run.loop_mode = Animation.LOOP_LINEAR
	_add_sprite_animation_track(anim_run, "Warrior_Run")
	_add_method_track(anim_run, 0.15, "emit_footstep", [])
	_add_method_track(anim_run, 0.45, "emit_footstep", [])
	anim_lib.add_animation("Run", anim_run)
	
	# Attack
	var anim_attack = Animation.new()
	anim_attack.length = 0.4 # 6 frames at 15fps
	_add_sprite_animation_track(anim_attack, "Warrior_Attack1")
	_add_method_track(anim_attack, 0.0, "emit_attack_start", [])
	_add_method_track(anim_attack, 0.2, "emit_attack_hit", [])
	_add_method_track(anim_attack, 0.4, "emit_attack_end", [])
	anim_lib.add_animation("Attack", anim_attack)
	
	# Roll (Fallback)
	var anim_roll = Animation.new()
	anim_roll.length = 0.5
	_add_sprite_animation_track(anim_roll, "Warrior_Run")
	_add_method_track(anim_roll, 0.0, "emit_roll_start", [])
	_add_method_track(anim_roll, 0.5, "emit_roll_end", [])
	anim_lib.add_animation("Roll", anim_roll)
	
	# Guard
	var anim_guard = Animation.new()
	anim_guard.length = 0.6
	anim_guard.loop_mode = Animation.LOOP_NONE
	_add_sprite_animation_track(anim_guard, "Warrior_Guard")
	_add_method_track(anim_guard, 0.0, "emit_guard_start", [])
	_add_method_track(anim_guard, 0.1, "emit_perfect_block_window_open", [])
	_add_method_track(anim_guard, 0.2, "emit_perfect_block_window_close", [])
	_add_method_track(anim_guard, 0.3, "emit_guard_hold", [])
	_add_method_track(anim_guard, 0.6, "emit_guard_end", [])
	anim_lib.add_animation("Guard", anim_guard)
	
	animation_player.add_animation_library("", anim_lib)
	animation_player.play("Idle")

func _add_sprite_animation_track(anim: Animation, sprite_anim: String) -> void:
	var track_idx = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track_idx, NodePath("AnimatedSprite2D:animation"))
	anim.track_insert_key(track_idx, 0.0, sprite_anim)

func _add_method_track(anim: Animation, time: float, method: String, args: Array) -> void:
	var track_idx = -1
	for i in range(anim.get_track_count()):
		if anim.track_get_type(i) == Animation.TYPE_METHOD and anim.track_get_path(i) == NodePath("PlayerAnimation"):
			track_idx = i
			break
	if track_idx == -1:
		track_idx = anim.add_track(Animation.TYPE_METHOD)
		anim.track_set_path(track_idx, NodePath("PlayerAnimation"))
		
	anim.track_insert_key(track_idx, time, {"method": method, "args": args})

func _add_animation_to_frames(frames: SpriteFrames, file_name: String) -> void:
	var path = ANIM_DIR + file_name
	var tex: Texture2D = load(path)
	if not tex: return
	
	var anim_name = file_name.get_basename()
	frames.add_animation(anim_name)
	frames.set_animation_loop(anim_name, true)
	
	# Faster for attacks, normal for rest
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
	if not character_body or not animated_sprite or not player_direction or not state_machine:
		return
		
	var sm = state_machine
	var state = sm.current_state
	
	# Play animations via AnimationPlayer
	if state == sm.State.ATTACK:
		if animation_player.current_animation != "Attack":
			animation_player.play("Attack")
	elif state == sm.State.ROLL:
		if animation_player.current_animation != "Roll":
			animation_player.play("Roll")
	elif state == sm.State.GUARD:
		if animation_player.current_animation != "Guard":
			animation_player.play("Guard")
	elif state == sm.State.RUN:
		if animation_player.current_animation != "Run":
			animation_player.play("Run")
	elif state == sm.State.WALK:
		if animation_player.current_animation != "Walk":
			animation_player.play("Walk")
	else:
		if animation_player.current_animation != "Idle":
			animation_player.play("Idle")
		
	# 1 = LEFT, 0 = RIGHT for Direction Enum
	if player_direction.current_direction == 1:
		animated_sprite.flip_h = true
	elif player_direction.current_direction == 0:
		animated_sprite.flip_h = false

# Explicit signal emitters for AnimationPlayer Method Tracks
func emit_attack_start() -> void: attack_start.emit()
func emit_attack_hit() -> void: attack_hit.emit()
func emit_attack_end() -> void: attack_end.emit()
func emit_roll_start() -> void: roll_start.emit()
func emit_roll_end() -> void: roll_end.emit()
func emit_footstep() -> void: footstep.emit()
func emit_guard_start() -> void: guard_start.emit()
func emit_guard_hold() -> void: guard_hold.emit()
func emit_guard_end() -> void: guard_end.emit()
func emit_perfect_block_window_open() -> void: perfect_block_window_open.emit()
func emit_perfect_block_window_close() -> void: perfect_block_window_close.emit()
