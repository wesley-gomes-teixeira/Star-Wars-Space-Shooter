extends Area2D

var speed = 400.0
var direction = Vector2.ZERO

func _ready():
	add_to_group("projectiles")
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("area_entered", Callable(self, "_on_area_entered"))

func _process(delta):
	position += direction * speed * delta
	
	# Remover se sair da tela
	var viewport_size = get_viewport_rect().size
	if position.x < -50 or position.x > viewport_size.x + 50 or \
	   position.y < -50 or position.y > viewport_size.y + 50:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("obstacles"):
		if body.has_method("take_damage"):
			body.take_damage()
		else:
			body.queue_free()
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("obstacles"):
		if area.has_method("take_damage"):
			area.take_damage()
		else:
			area.queue_free()
		queue_free()
