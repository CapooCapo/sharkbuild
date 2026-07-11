class_name HitBox
extends Area2D

## Attaches to Area2D nodes that deal damage.
## Exposes a get_damage_payload() method for HurtBoxes to read.

var source_stats: Node
var damage_amount: int = 0

func get_damage_payload() -> DamagePayload:
	var payload = DamagePayload.new()
	payload.amount = damage_amount
	payload.source = source_stats
	return payload
