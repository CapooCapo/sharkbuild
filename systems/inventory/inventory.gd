class_name Inventory
extends Node

signal inventory_changed
signal slot_changed(index: int)

@export var capacity: int = 20
var slots: Array[InventorySlot] = []

func _ready() -> void:
	for i in range(capacity):
		slots.append(InventorySlot.new())

const DEBUG_LOOT: bool = true

func add_item(item: ItemData, amount: int = 1) -> int:
	var remaining = amount
	
	# Try to stack in existing slots first
	for i in range(slots.size()):
		var slot = slots[i]
		if not slot.is_empty() and slot.item == item:
			remaining = slot.add(remaining)
			slot_changed.emit(i)
			if remaining <= 0:
				inventory_changed.emit()
				if DEBUG_LOOT: print("[DEBUG_LOOT] Inventory Updated: Added to existing stack.")
				return 0
				
	# If still remaining, find empty slots
	for i in range(slots.size()):
		var slot = slots[i]
		if slot.is_empty():
			slot.item = item
			remaining = slot.add(remaining)
			slot_changed.emit(i)
			if remaining <= 0:
				inventory_changed.emit()
				if DEBUG_LOOT: print("[DEBUG_LOOT] Inventory Updated: Added to new slot.")
				return 0
				
	inventory_changed.emit()
	if DEBUG_LOOT: print("[DEBUG_LOOT] Inventory Updated: Remaining ", remaining)
	return remaining

func remove_item(item: ItemData, amount: int = 1) -> int:
	var remaining = amount
	for i in range(slots.size() - 1, -1, -1):
		var slot = slots[i]
		if not slot.is_empty() and slot.item == item:
			remaining = slot.remove(remaining)
			slot_changed.emit(i)
			if remaining <= 0:
				inventory_changed.emit()
				return 0
				
	inventory_changed.emit()
	return remaining

func has_item(item: ItemData, amount: int = 1) -> bool:
	return get_item_count(item) >= amount

func get_item_count(item: ItemData) -> int:
	var total = 0
	for slot in slots:
		if not slot.is_empty() and slot.item == item:
			total += slot.quantity
	return total

func clear() -> void:
	for i in range(capacity):
		slots[i].clear()
		slot_changed.emit(i)
	inventory_changed.emit()

func first_empty_slot() -> int:
	for i in range(capacity):
		if slots[i].is_empty():
			return i
	return -1

func sort() -> void:
	# Basic sort by name, then by quantity
	var non_empty = slots.filter(func(s): return not s.is_empty())
	non_empty.sort_custom(func(a, b): 
		if a.item.name != b.item.name:
			return a.item.name < b.item.name
		return a.quantity > b.quantity
	)
	
	slots.clear()
	slots.append_array(non_empty)
	
	while slots.size() < capacity:
		slots.append(InventorySlot.new())
		
	for i in range(capacity):
		slot_changed.emit(i)
	inventory_changed.emit()

func is_full() -> bool:
	for slot in slots:
		if slot.is_empty():
			return false
	return true
