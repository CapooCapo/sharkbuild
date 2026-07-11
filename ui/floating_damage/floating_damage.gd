class_name FloatingDamage
extends Node2D

var amount: int = 0
var type: int = DamageType.Type.NORMAL

@onready var label: Label = $Label

func _ready() -> void:
	# Randomize X position slightly
	position.x += randf_range(-8.0, 8.0)
	
	_setup_visuals()
	_play_animation()

func _setup_visuals() -> void:
	if not label: return
	
	# Format text
	match type:
		DamageType.Type.HEAL:
			label.text = "+%d" % amount
		DamageType.Type.CRITICAL:
			label.text = "-%d!" % amount
		_:
			label.text = "-%d" % amount
	
	var settings = LabelSettings.new()
	settings.outline_size = 4
	settings.outline_color = Color("#000000")
	
	match type:
		DamageType.Type.HEAL:
			settings.font_color = Color("#4CFF5A")
			settings.font_size = 20
		DamageType.Type.CRITICAL:
			settings.font_color = Color("#FFD54A")
			settings.font_size = 28
		DamageType.Type.POISON:
			settings.font_color = Color("#9DFF5A")
			settings.font_size = 20
		DamageType.Type.FIRE:
			settings.font_color = Color("#FF7A2D")
			settings.font_size = 20
		_:
			settings.font_color = Color("#FF3B30")
			settings.font_size = 20
		
	label.label_settings = settings
	
	# Center the label
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.position = Vector2(-50, -20) # Approximate centering based on 100x40 size

func _play_animation() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Move Y
	tween.tween_property(self, "position:y", position.y - 42.0, 0.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	# Fade
	tween.tween_property(self, "modulate:a", 0.0, 0.6).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	
	# Scale pop
	scale = Vector2(0.8, 0.8)
	var peak_scale = 1.4 if type == DamageType.Type.CRITICAL else 1.0
	
	var scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", Vector2(peak_scale, peak_scale), 0.1).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(self, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_IN).set_delay(0.1)
	
	# Shake if critical
	if type == DamageType.Type.CRITICAL:
		var shake_tween = create_tween()
		shake_tween.set_loops(4)
		shake_tween.tween_property(self, "position:x", position.x + 3.0, 0.05)
		shake_tween.tween_property(self, "position:x", position.x - 3.0, 0.05)
	
	# Cleanup
	get_tree().create_timer(0.6).timeout.connect(queue_free)
