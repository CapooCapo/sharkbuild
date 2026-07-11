class_name LootEntry
extends Resource

@export var item: ItemData
@export var minimum_amount: int = 1
@export var maximum_amount: int = 1
@export var drop_weight: float = 1.0

func get_amount() -> int:
	if minimum_amount == maximum_amount:
		return minimum_amount
	return randi_range(minimum_amount, maximum_amount)
