class_name EnemyPopupSpawner
extends Node

var enemy_stats: EnemyStats
var spawn_position_node: Node2D

const EXP_POPUP_SCENE = preload("res://ui/hud/exp_popup.tscn")

func _ready() -> void:
	if not enemy_stats or not spawn_position_node:
		push_warning("EnemyPopupSpawner is missing references")
		return
		
	enemy_stats.died.connect(_on_died)

func _on_died() -> void:
	if not EXP_POPUP_SCENE: return
	
	var popup = EXP_POPUP_SCENE.instantiate() as ExpPopup
	popup.exp_amount = enemy_stats.exp_reward
	
	var tree = get_tree()
	if tree and tree.current_scene:
		tree.current_scene.add_child(popup)
		popup.global_position = spawn_position_node.global_position + Vector2(0, -20)
