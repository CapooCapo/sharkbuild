class_name GameMenu
extends CanvasLayer

@onready var tab_bar: TabBar = $Panel/VBoxContainer/TabBar
@onready var content: MarginContainer = $Panel/VBoxContainer/Content

var pages: Array[Control] = []
var current_tab: int = 0
var inventory: Inventory = null # Injected by Player

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	
	_setup_inputs()
	_setup_pages()
	
	if tab_bar:
		tab_bar.tab_changed.connect(_on_tab_changed)

func _setup_inputs() -> void:
	if not InputMap.has_action("menu"):
		InputMap.add_action("menu")
		var ev = InputEventKey.new()
		ev.physical_keycode = KEY_TAB
		InputMap.action_add_event("menu", ev)

func _setup_pages() -> void:
	if not content or not tab_bar:
		return
		
	# Instantiate Inventory Page
	var inv_scene = preload("res://ui/inventory/inventory_ui.tscn")
	var inv_page = null
	if inv_scene:
		inv_page = inv_scene.instantiate() as InventoryUI
		if inv_page and inventory:
			inv_page.inventory = inventory
			# Remove background style from the inventory UI since GameMenu has one
			var panel = inv_page.get_node_or_null("PanelContainer")
			if panel:
				panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
				
	# Create placeholders for others
	var tabs = ["Inventory", "Equipment", "Character", "Skills", "Quest", "Crafting", "Settings"]
	
	for i in range(tabs.size()):
		var title = tabs[i]
		tab_bar.add_tab(title)
		
		var page_control: Control
		if title == "Inventory" and inv_page:
			page_control = inv_page
		else:
			page_control = _create_placeholder(title)
			
		content.add_child(page_control)
		pages.append(page_control)
		
	_show_page(0)

func _create_placeholder(title: String) -> Control:
	var ctrl = Control.new()
	ctrl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ctrl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ctrl.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var label = Label.new()
	label.text = title + " Page (WIP)"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	ctrl.add_child(label)
	return ctrl

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		if visible:
			close_menu()
		else:
			open_menu()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel") and visible:
		close_menu()
		get_viewport().set_input_as_handled()

func open_menu() -> void:
	show()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close_menu() -> void:
	hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_tab_changed(tab_idx: int) -> void:
	_show_page(tab_idx)

func _show_page(idx: int) -> void:
	if idx < 0 or idx >= pages.size():
		return
	current_tab = idx
	for i in range(pages.size()):
		pages[i].visible = (i == idx)
