class_name Interactable
extends Area2D

## Base class for objects that can be interacted with.

signal interacted(interactor: Node)

@export var interaction_text: String = "Interacted!"

func _ready() -> void:
	collision_layer = 0
	collision_mask = 0
	# Interaction layer (let's say bit 3, value 4)
	set_collision_layer_value(3, true)

func interact(interactor: Node) -> void:

	interacted.emit(interactor)
