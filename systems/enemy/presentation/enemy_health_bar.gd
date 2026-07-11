class_name EnemyHealthBar
extends Node

var enemy_stats: EnemyStats
var progress_bar: ProgressBar

var _health_bar_timer: Timer
var _hp_tween: Tween

func _ready() -> void:
	if not enemy_stats or not progress_bar:
		push_warning("EnemyHealthBar is missing references")
		return
		
	enemy_stats.hp_changed.connect(_on_hp_changed)
	enemy_stats.died.connect(_on_died)
	
	progress_bar.hide()
	
	_health_bar_timer = Timer.new()
	_health_bar_timer.wait_time = 3.0
	_health_bar_timer.one_shot = true
	_health_bar_timer.timeout.connect(progress_bar.hide)
	add_child(_health_bar_timer)

func _on_hp_changed(current: int, max_val: int) -> void:
	progress_bar.max_value = max_val
	
	if current < max_val and not enemy_stats.is_dead():
		progress_bar.show()
		_health_bar_timer.start()
		
		if _hp_tween and _hp_tween.is_valid():
			_hp_tween.kill()
		_hp_tween = create_tween()
		_hp_tween.tween_property(progress_bar, "value", float(current), 0.2).set_trans(Tween.TRANS_SINE)
		
	elif current == max_val:
		progress_bar.value = current
		progress_bar.hide()

func _on_died() -> void:
	progress_bar.hide()
