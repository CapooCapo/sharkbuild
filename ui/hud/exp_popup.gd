extends Node2D
class_name ExpPopup

@export var exp_amount: int = 25
@onready var label: Label = $Label

func _ready() -> void:
	if label:
		label.text = "+%d EXP" % exp_amount
		# Animate
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "position", position + Vector2(0, -40), 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.chain().tween_callback(queue_free)
