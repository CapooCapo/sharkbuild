class_name WorldItem
extends Node2D

@export var item_data: ItemData
@export var amount: int = 1

@onready var sprite: Sprite2D = $Sprite2D
@onready var interactable: Interactable = $Interactable
@onready var amount_label: Label = $AmountLabel

var _time: float = 0.0
var _start_y: float = 0.0

func _ready() -> void:
	_start_y = position.y
	
	if item_data:
		if not item_data.icon:
			push_warning("Missing icon for ItemData: ", item_data.name)
		else:
			sprite.texture = item_data.icon
		
	if amount_label:
		if amount > 1:
			amount_label.text = "x" + str(amount)
			amount_label.show()
		else:
			amount_label.hide()

func initialize(data: ItemData, quantity: int = 1) -> void:
	item_data = data
	amount = quantity
	# Visuals will update in _ready() after node enters tree

func pickup(inventory: Inventory) -> bool:
	if not item_data or not inventory:
		return false
		
	var remaining = inventory.add_item(item_data, amount)
	if remaining < amount:
		amount = remaining
		if amount <= 0:
			queue_free()
		return true
	return false


