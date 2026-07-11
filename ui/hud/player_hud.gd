class_name PlayerHUD
extends CanvasLayer

var exp_bar: TextureProgressBar
var level_label: Label
var hp_label: Label
var mana_label: Label
var stamina_label: Label

var exp_tween: Tween

const BARS_DIR = "res://assets/Tiny Swords (Free Pack)/UI Elements/UI Elements/Bars/"

func _ready() -> void:
	# Build the UI Programmatically with Responsive Anchors
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_TOP_LEFT)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_left", 8)
	add_child(margin)
	
	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.08, 0.85) # Dark modern translucent panel
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left = 8
	style.content_margin_top = 8
	style.content_margin_right = 8
	style.content_margin_bottom = 8
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.2, 0.2, 0.2, 0.8)
	# Add subtle shadow
	style.shadow_color = Color(0, 0, 0, 0.4)
	style.shadow_size = 4
	style.shadow_offset = Vector2(0, 2)
	panel.add_theme_stylebox_override("panel", style)
	margin.add_child(panel)
	
	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 8)
	panel.add_child(main_vbox)
	
	# Load Textures
	var small_base = load(BARS_DIR + "SmallBar_Base.png")
	var small_fill = load(BARS_DIR + "SmallBar_Fill.png")
	
	var icon_hp = load("res://assets/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_01.png")
	var icon_mana = load("res://assets/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_02.png")
	var icon_stamina = load("res://assets/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_03.png")
	
	# --- Header (Portrait, Name) ---
	var header = HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	main_vbox.add_child(header)
	
	# Portrait placeholder (32x32 frame)
	var portrait_frame = PanelContainer.new()
	var port_style = StyleBoxFlat.new()
	port_style.bg_color = Color(0.15, 0.15, 0.15, 1.0)
	port_style.border_width_left = 1
	port_style.border_width_top = 1
	port_style.border_width_right = 1
	port_style.border_width_bottom = 1
	port_style.border_color = Color(0.3, 0.3, 0.3, 1.0)
	port_style.corner_radius_top_left = 2
	port_style.corner_radius_top_right = 2
	port_style.corner_radius_bottom_left = 2
	port_style.corner_radius_bottom_right = 2
	portrait_frame.add_theme_stylebox_override("panel", port_style)
	portrait_frame.custom_minimum_size = Vector2(32, 32)
	header.add_child(portrait_frame)
	
	# Identity VBox
	var identity_vbox = VBoxContainer.new()
	identity_vbox.add_theme_constant_override("separation", 0)
	identity_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	identity_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_child(identity_vbox)
	
	var name_label = Label.new()
	name_label.text = "Warrior"
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_font_override("font", ThemeDB.fallback_font) # Bold emphasis
	identity_vbox.add_child(name_label)
	
	# --- Divider ---
	var div1 = ColorRect.new()
	div1.color = Color(1, 1, 1, 0.1)
	div1.custom_minimum_size = Vector2(0, 1)
	main_vbox.add_child(div1)
	
	# --- Body (HP, Mana, Stamina) Numeric Only ---
	var body_vbox = VBoxContainer.new()
	body_vbox.add_theme_constant_override("separation", 4)
	main_vbox.add_child(body_vbox)
	
	# Function to create a numeric row
	var create_row = func(icon_tex: Texture2D, name: String, color: Color) -> Array:
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		
		var icon_rect = TextureRect.new()
		icon_rect.texture = icon_tex
		icon_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon_rect.custom_minimum_size = Vector2(16, 16)
		icon_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(icon_rect)
		
		var name_lbl = Label.new()
		name_lbl.text = name
		name_lbl.add_theme_font_size_override("font_size", 12)
		name_lbl.add_theme_color_override("font_color", color)
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_lbl)
		
		var val_lbl = Label.new()
		val_lbl.text = "100 / 100"
		val_lbl.add_theme_font_size_override("font_size", 12)
		val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		val_lbl.custom_minimum_size = Vector2(65, 0) # Right-aligned fixed block
		row.add_child(val_lbl)
		
		return [row, val_lbl]
		
	var hp_row = create_row.call(icon_hp, "HP", Color("#D32F2F"))
	body_vbox.add_child(hp_row[0])
	hp_label = hp_row[1]
	
	var mana_row = create_row.call(icon_mana, "Mana", Color("#1976D2"))
	body_vbox.add_child(mana_row[0])
	mana_label = mana_row[1]
	
	var stam_row = create_row.call(icon_stamina, "Stamina", Color("#43A047"))
	body_vbox.add_child(stam_row[0])
	stamina_label = stam_row[1]
	
	# --- Divider ---
	var div2 = ColorRect.new()
	div2.color = Color(1, 1, 1, 0.1)
	div2.custom_minimum_size = Vector2(0, 1)
	main_vbox.add_child(div2)
	
	# --- Footer (EXP & Level) ---
	var footer_hbox = HBoxContainer.new()
	footer_hbox.add_theme_constant_override("separation", 8)
	main_vbox.add_child(footer_hbox)
	
	exp_bar = TextureProgressBar.new()
	exp_bar.texture_under = small_base
	exp_bar.texture_progress = small_fill
	exp_bar.tint_progress = Color("#F9A825")
	exp_bar.nine_patch_stretch = true
	exp_bar.custom_minimum_size = Vector2(100, 6) # Thin EXP bar
	exp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	exp_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	footer_hbox.add_child(exp_bar)
	
	level_label = Label.new()
	level_label.text = "Lv. 1"
	level_label.add_theme_font_size_override("font_size", 11)
	level_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	footer_hbox.add_child(level_label)
	
func initialize(stats: CharacterStats) -> void:
	if not stats:
		return
		
	# Connect Signals
	stats.hp_changed.connect(_on_hp_changed)
	stats.mana_changed.connect(_on_mana_changed)
	stats.stamina_changed.connect(_on_stamina_changed)
	stats.exp_changed.connect(_on_exp_changed)
	stats.level_changed.connect(_on_level_changed)
	
	# Initial Sync
	_on_hp_changed(stats.current_hp, stats.player_data.max_hp)
	_on_mana_changed(stats.current_mana, stats.player_data.max_mana)
	_on_stamina_changed(stats.current_stamina, stats.player_data.max_stamina)
	_on_exp_changed(stats.current_exp, stats.required_exp())
	_on_level_changed(stats.current_level)

func _on_hp_changed(current: int, maximum: int) -> void:
	hp_label.text = str(current) + " / " + str(maximum)
	
	if float(current) / float(maximum) <= 0.25:
		hp_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2)) # Critical Red
	else:
		hp_label.remove_theme_color_override("font_color")

func _on_mana_changed(current: int, maximum: int) -> void:
	mana_label.text = str(current) + " / " + str(maximum)

func _on_stamina_changed(current: float, maximum: float) -> void:
	stamina_label.text = str(int(current)) + " / " + str(int(maximum))

func _on_exp_changed(current: int, required: int) -> void:
	exp_bar.max_value = required
	
	if exp_tween and exp_tween.is_valid():
		exp_tween.kill()
	exp_tween = create_tween()
	exp_tween.tween_property(exp_bar, "value", current, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_level_changed(current: int) -> void:
	level_label.text = "Lv. " + str(current)
