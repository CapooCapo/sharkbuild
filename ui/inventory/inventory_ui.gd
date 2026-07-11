class_name InventoryUI
extends Control

@export var inventory: Inventory
@export var slot_ui_scene: PackedScene = preload("res://ui/inventory/inventory_slot_ui.tscn")

@onready var grid: GridContainer = $PanelContainer/VBoxContainer/GridContainer

var slot_uis: Array[InventorySlotUI] = []

func _ready() -> void:
	if not inventory:
		push_warning("InventoryUI: No inventory assigned!")
		return
		
	_initialize_grid()
	
	inventory.inventory_changed.connect(_on_inventory_changed)
	inventory.slot_changed.connect(_on_slot_changed)
	
	_on_inventory_changed()

func _initialize_grid() -> void:
	for child in grid.get_children():
		child.queue_free()
	slot_uis.clear()
	
	for i in range(inventory.capacity):
		var slot_ui = slot_ui_scene.instantiate() as InventorySlotUI
		slot_ui.slot_index = i
		grid.add_child(slot_ui)
		slot_uis.append(slot_ui)

func _on_inventory_changed() -> void:
	for i in range(inventory.capacity):
		_on_slot_changed(i)

func _on_slot_changed(index: int) -> void:
	if index < 0 or index >= slot_uis.size():
		return
		
	var slot = inventory.slots[index]
	slot_uis[index].update(slot)
