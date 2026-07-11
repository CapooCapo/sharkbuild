class_name LootTable
extends Resource

@export var entries: Array[LootEntry] = []

func roll() -> Dictionary:
	if entries.is_empty():
		return {}
		
	var total_weight: float = 0.0
	for entry in entries:
		if entry:
			total_weight += entry.drop_weight
			
	if total_weight <= 0:
		return {}
		
	var rand = randf_range(0.0, total_weight)
	var current_weight: float = 0.0
	
	for entry in entries:
		if not entry or not entry.item:
			continue
		current_weight += entry.drop_weight
		if rand <= current_weight:
			return {"item": entry.item, "amount": entry.get_amount()}
			
	# Fallback (should theoretically never hit due to float precision but just in case)
	for i in range(entries.size() - 1, -1, -1):
		var e = entries[i]
		if e and e.item:
			return {"item": e.item, "amount": e.get_amount()}
	return {}

func roll_multiple(count: int) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	for i in range(count):
		var res = roll()
		if not res.is_empty():
			results.append(res)
	return results
