class_name DamagePresenter
extends Node

var stats_node: Node
var damage_manager: FloatingDamageManager
var entity_node: Node2D

func _ready() -> void:
	if stats_node:
		if stats_node.has_signal("damage_taken"):
			stats_node.damage_taken.connect(_on_damage_taken)
		if stats_node.has_signal("healed"):
			stats_node.healed.connect(_on_healed)

func _on_damage_taken(amount: int, type: int = DamageType.Type.NORMAL) -> void:
	if damage_manager and entity_node:
		damage_manager.spawn_damage(entity_node.global_position + Vector2(0, -24), amount, type)

func _on_healed(amount: int) -> void:
	if damage_manager and entity_node:
		damage_manager.spawn_damage(entity_node.global_position + Vector2(0, -24), amount, DamageType.Type.HEAL)
