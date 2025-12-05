extends Area2D

signal bad_collected

var velocity = Vector2.ZERO
var speed = 100.0
var is_moving = false

func _ready():
	add_to_group("asteroids")
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	# 30% de chance de ser um meteoro móvel
	if randf() < 0.3:
		is_moving = true
		# Direção aleatória
		var angle = randf() * TAU
		velocity = Vector2(cos(angle), sin(angle)) * speed

func _process(delta):
	if is_moving:
		position += velocity * delta
		
		# Se sair da tela, remove
		var viewport_size = get_viewport_rect().size
		if position.x < -100 or position.x > viewport_size.x + 100 or \
		   position.y < -100 or position.y > viewport_size.y + 100:
			queue_free()

func _on_body_entered(body):
	if body.name == "Player":
		emit_signal("bad_collected")
		queue_free()
