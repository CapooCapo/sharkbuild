class_name EnemySensor
extends Area2D

signal player_detected(player: Node2D)
signal player_lost()
signal target_changed(player: Node2D)

@export var enemy_data: EnemyData

var _target_player: Node2D = null

func _ready() -> void:
	# Attempt to set radius from EnemyData
	if enemy_data and enemy_data.get("detection_radius") != null:
		var col = get_node_or_null("CollisionShape2D") as CollisionShape2D
		if col and col.shape is CircleShape2D:
			col.shape.radius = enemy_data.detection_radius
			
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_target_player = body
		player_detected.emit(body)
		target_changed.emit(body)

func _on_body_exited(body: Node2D) -> void:
	if body == _target_player:
		_target_player = null
		player_lost.emit()
		target_changed.emit(null)

# Public API

func has_target() -> bool:
	return _target_player != null

func get_target() -> Node2D:
	return _target_player

func get_target_position() -> Vector2:
	if _target_player:
		return _target_player.global_position
	return Vector2.ZERO

func get_distance_to_target() -> float:
	if _target_player:
		return global_position.distance_to(_target_player.global_position)
	return INF

func is_target_visible() -> bool:
	# For now, if we have a target in the Area2D, it's considered visible.
	# In the future, this can be backed by a RayCast2D for line of sight checking.
	return has_target()

func clear_target() -> void:
	if _target_player != null:
		_target_player = null
		player_lost.emit()
		target_changed.emit(null)

func _draw() -> void:
	if OS.is_debug_build():
		var radius = 160.0
		if enemy_data and enemy_data.get("detection_radius") != null:
			radius = enemy_data.detection_radius
		draw_circle(Vector2.ZERO, radius, Color(1, 0, 0, 0.1))
		
		if _target_player:
			var local_pos = to_local(_target_player.global_position)
			draw_line(Vector2.ZERO, local_pos, Color(1, 0, 0, 0.5), 2.0)
			draw_circle(local_pos, 5.0, Color(1, 0, 0, 0.8))

func _process(_delta: float) -> void:
	if OS.is_debug_build():
		queue_redraw()
