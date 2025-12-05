extends StaticBody2D

var planet_colors = [
	Color(0.8, 0.3, 0.2, 1),   # Vermelho (Marte)
	Color(0.4, 0.6, 0.9, 1),   # Azul (Netuno)
	Color(0.9, 0.7, 0.3, 1),   # Amarelo/Laranja (Júpiter)
	Color(0.5, 0.3, 0.6, 1),   # Roxo
	Color(0.3, 0.8, 0.4, 1),   # Verde
	Color(0.9, 0.5, 0.2, 1),   # Laranja (Saturno)
	Color(0.6, 0.8, 0.9, 1),   # Azul claro (Urano)
	Color(0.85, 0.85, 0.7, 1), # Bege (Vênus)
]

var max_health = 5
var current_health = 5

func _ready():
	add_to_group("obstacles")
	
	# Randomizar cor da Estrela da Morte
	var random_color = planet_colors[randi() % planet_colors.size()]
	$DeathStarBody.color = random_color
	$Atmosphere.color = Color(random_color.r, random_color.g, random_color.b, 0.3)
	var darker_color = Color(random_color.r * 0.8, random_color.g * 0.8, random_color.b * 0.8)
	$SuperlaserDish.color = darker_color
	$PanelLine1.color = darker_color
	$PanelLine2.color = darker_color

func take_damage():
	current_health -= 1
	
	# Efeito visual de dano - piscar
	var tween = create_tween()
	modulate = Color(1, 0.5, 0.5)
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.2)
	
	if current_health <= 0:
		# Tocar som de explosão
		$ExplosionSound.play()
		
		# Efeito de explosão
		var explosion_particles = CPUParticles2D.new()
		explosion_particles.position = position
		explosion_particles.emitting = true
		explosion_particles.one_shot = true
		explosion_particles.amount = 30
		explosion_particles.lifetime = 1.0
		explosion_particles.explosiveness = 1.0
		explosion_particles.direction = Vector2(0, 0)
		explosion_particles.spread = 180.0
		explosion_particles.gravity = Vector2(0, 0)
		explosion_particles.initial_velocity_min = 50.0
		explosion_particles.initial_velocity_max = 150.0
		explosion_particles.scale_amount_min = 3.0
		explosion_particles.scale_amount_max = 6.0
		explosion_particles.color = $DeathStarBody.color
		get_parent().add_child(explosion_particles)
		
		# Aguardar o som terminar antes de remover
		await get_tree().create_timer(1.0).timeout
		explosion_particles.queue_free()
		
		queue_free()
