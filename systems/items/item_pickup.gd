class_name ItemPickup
extends Node

@onready var world_item: WorldItem = get_parent()

func _ready() -> void:
	# Connect to the interactable sibling if it exists
	var interactable = world_item.get_node_or_null("Interactable")
	if interactable and interactable is Interactable:
		interactable.interacted.connect(_on_interacted)

const DEBUG_LOOT: bool = true

func _on_interacted(interactor: Node) -> void:
	if not world_item.item_data:
		return
		
	# Find Inventory component on the interactor
	var inventory: Inventory = null
	for child in interactor.get_children():
		if child is Inventory:
			inventory = child
			break
			
	if not inventory:
		push_warning("ItemPickup: Interactor has no Inventory component.")
		return
		
	# Try to add item
	if not world_item.pickup(inventory):
		# Inventory full
		if DEBUG_LOOT: print("[DEBUG_LOOT] Pickup failed: Inventory full.")
	else:
		if DEBUG_LOOT: print("[DEBUG_LOOT] Pickup Collected.")
