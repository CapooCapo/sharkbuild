class_name HurtBox
extends Area2D

## Attaches to Area2D nodes that receive damage.
## Forwards the damage payload to the CombatController.
## Does NOT apply gameplay directly.

signal hit_received(payload: DamagePayload)

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("get_damage_payload"):
		hit_received.emit(area.get_damage_payload())
