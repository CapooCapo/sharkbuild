class_name CameraManager
extends Node

## Independent script to manage camera tracking.

@export var camera_2d: Camera2D
var target_node: Node2D

func _process(delta: float) -> void:
	if target_node and camera_2d:
		# Smooth interpolation
		camera_2d.global_position = camera_2d.global_position.lerp(target_node.global_position, 5.0 * delta)

func set_target(node: Node2D) -> void:
	target_node = node
	if camera_2d and target_node:
		camera_2d.global_position = target_node.global_position

