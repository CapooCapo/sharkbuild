class_name FloatingDamageManager
extends Node

const POPUP_SCENE = preload("res://ui/floating_damage/floating_damage.tscn")

func _ready() -> void:
	add_to_group("damage_manager")

func spawn_damage(world_position: Vector2, amount: int, type: int = DamageType.Type.NORMAL) -> void:
	var popup = POPUP_SCENE.instantiate()
	popup.amount = amount
	popup.type = type
	
	add_child(popup)
	popup.global_position = world_position
