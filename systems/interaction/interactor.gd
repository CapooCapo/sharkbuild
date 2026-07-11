class_name Interactor
extends Area2D

## Component for players/NPCs to trigger Interactables.

func _ready() -> void:
	collision_layer = 0
	collision_mask = 0
	# Scan for interaction layer (bit 3, value 4)
	set_collision_mask_value(3, true)

func try_interact() -> void:
	var overlapping = get_overlapping_areas()
	for area in overlapping:
		if area is Interactable:
			area.interact(owner)
			return # Interact with the first one found
