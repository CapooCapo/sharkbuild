class_name InventorySlotUI
extends PanelContainer

@onready var icon_rect: TextureRect = $MarginContainer/IconRect
@onready var count_label: Label = $CountLabel
@onready var highlight: ColorRect = $Highlight

var slot_index: int = -1
var current_slot: InventorySlot = null

func _ready() -> void:
	highlight.hide()

func update(slot: InventorySlot) -> void:
	current_slot = slot
	
	if not slot or slot.is_empty():
		icon_rect.texture = null
		count_label.text = ""
		tooltip_text = ""
	else:
		icon_rect.texture = slot.item.icon
		count_label.text = str(slot.quantity) if slot.quantity > 1 else ""
		tooltip_text = slot.item.name + "\\n" + slot.item.description

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		highlight.show()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print_debug("Clicked slot ", slot_index)

func _mouse_exited() -> void:
	highlight.hide()
