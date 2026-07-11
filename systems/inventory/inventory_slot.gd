class_name InventorySlot
extends Resource

@export var item: ItemData
@export var quantity: int = 0

func is_empty() -> bool:
	return item == null or quantity <= 0

func add(amount: int) -> int:
	if not item: return amount
	var space = item.max_stack - quantity
	if amount <= space:
		quantity += amount
		return 0
	else:
		quantity = item.max_stack
		return amount - space

func remove(amount: int) -> int:
	if quantity >= amount:
		quantity -= amount
		if quantity <= 0:
			clear()
		return 0
	else:
		var remainder = amount - quantity
		clear()
		return remainder

func clear() -> void:
	item = null
	quantity = 0
