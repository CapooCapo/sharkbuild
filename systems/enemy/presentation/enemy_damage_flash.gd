class_name EnemyDamageFlash
extends Node

var enemy_stats: EnemyStats
var animated_sprite: AnimatedSprite2D

var _flash_tween: Tween

func _ready() -> void:
	if not enemy_stats or not animated_sprite:
		push_warning("EnemyDamageFlash is missing references")
		return
		
	enemy_stats.took_damage.connect(_on_took_damage)

func _on_took_damage(_amount: int) -> void:
	if not enemy_stats.is_dead():
		_play_damage_feedback()

func _play_damage_feedback() -> void:
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
		
	_flash_tween = create_tween()
	
	animated_sprite.modulate = Color(1.0, 0.4, 0.4, 1.0)
	animated_sprite.scale = Vector2(1.2, 0.8)
	
	_flash_tween.set_parallel(true)
	_flash_tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.15)
	_flash_tween.tween_property(animated_sprite, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
