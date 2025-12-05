extends CharacterBody2D

@export var speed: float = 200.0
@export var rotation_speed: float = 5.0
@export var fire_rate: float = 0.3

var can_shoot = true
var projectile_scene = preload("res://projectile.tscn")

func _physics_process(delta):
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	
	if direction != Vector2.ZERO:
		velocity = direction.normalized() * speed
		
		# Rotacionar nave na direção do movimento
		var target_rotation = direction.angle()
		rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)
	else:
		velocity = Vector2.ZERO
	
	# Atirar com espaço
	if Input.is_action_pressed("ui_accept") and can_shoot:
		shoot()
	
	move_and_slide()

	# Impede o jogador de sair da tela
	var screen_size = get_viewport_rect().size
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

func shoot():
	can_shoot = false
	var projectile = projectile_scene.instantiate()
	projectile.position = position
	projectile.direction = Vector2(cos(rotation), sin(rotation))
	projectile.rotation = rotation
	get_parent().add_child(projectile)
	
	# Tocar som de laser
	$LaserSound.play()
	
	# Cooldown de tiro
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true
