extends Area2D

signal collected(points)

enum StarType { NORMAL, GOLDEN, SPECIAL }
@export var type: StarType = StarType.NORMAL

var points_value = 1

func _ready():
	add_to_group("stars")
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	# Configurar valor e cor baseado no tipo
	match type:
		StarType.NORMAL:
			points_value = 1
			modulate = Color(1, 1, 0)  # Amarelo
		StarType.GOLDEN:
			points_value = 5
			modulate = Color(1, 0.84, 0)  # Dourado
			# Aumentar tamanho
			scale = Vector2(1.3, 1.3)
		StarType.SPECIAL:
			points_value = 3
			modulate = Color(0.5, 1, 1)  # Ciano
			# Animação piscante
			var tween = create_tween()
			tween.set_loops()
			tween.tween_property(self, "modulate:a", 0.3, 0.5)
			tween.tween_property(self, "modulate:a", 1.0, 0.5)
	
	# Brilho para todas as estrelas
	var tween_rotate = create_tween()
	tween_rotate.set_loops()
	tween_rotate.tween_property(self, "rotation", TAU, 2.0)

func _on_body_entered(body):
	if body.name == "Player":
		emit_signal("collected", points_value)
		queue_free()
