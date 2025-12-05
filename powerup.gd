extends Area2D

signal collected(type)

enum PowerUpType { SPEED, SHIELD, DOUBLE_POINTS }
@export var type: PowerUpType = PowerUpType.SPEED

func _ready():
	add_to_group("powerups")
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	# Animar power-up (rotação e flutuação)
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "rotation", TAU, 3.0)
	
	var tween2 = create_tween()
	tween2.set_loops()
	tween2.tween_property(self, "position:y", position.y - 10, 1.0)
	tween2.tween_property(self, "position:y", position.y + 10, 1.0)

func _on_body_entered(body):
	if body.name == "Player":
		emit_signal("collected", type)
		queue_free()
