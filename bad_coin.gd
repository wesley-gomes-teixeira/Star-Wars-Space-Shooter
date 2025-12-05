extends Area2D

signal bad_collected

var asteroid_colors = [
	{"base": Color(0.4, 0.35, 0.3, 1), "dark": Color(0.35, 0.3, 0.25, 1)},      # Marrom
	{"base": Color(0.5, 0.45, 0.4, 1), "dark": Color(0.4, 0.35, 0.3, 1)},       # Cinza marrom
	{"base": Color(0.35, 0.35, 0.35, 1), "dark": Color(0.25, 0.25, 0.25, 1)},   # Cinza escuro
	{"base": Color(0.45, 0.4, 0.35, 1), "dark": Color(0.35, 0.3, 0.25, 1)},     # Bege escuro
	{"base": Color(0.3, 0.28, 0.26, 1), "dark": Color(0.2, 0.18, 0.16, 1)},     # Marrom muito escuro
	{"base": Color(0.55, 0.5, 0.45, 1), "dark": Color(0.45, 0.4, 0.35, 1)},     # Cinza claro
	{"base": Color(0.38, 0.32, 0.28, 1), "dark": Color(0.28, 0.22, 0.18, 1)},   # Chocolate
]

var teleport_timer = 0.0
var teleport_interval = 3.0

func _ready():
	add_to_group("asteroids")
	connect("body_entered", Callable(self, "_on_body_entered"))
	teleport_interval = randf_range(2.0, 3.5)
	
	# Randomizar cor do TIE Fighter
	var color_pair = asteroid_colors[randi() % asteroid_colors.size()]
	$Cockpit.color = color_pair.base
	$CockpitWindow.color = Color(color_pair.dark.r * 0.5, color_pair.dark.g * 0.8, color_pair.dark.b * 0.5)
	$LeftWing.color = color_pair.dark
	$RightWing.color = color_pair.dark
	$LeftWingFrame.color = Color(color_pair.dark.r * 0.6, color_pair.dark.g * 0.6, color_pair.dark.b * 0.7)
	$RightWingFrame.color = Color(color_pair.dark.r * 0.6, color_pair.dark.g * 0.6, color_pair.dark.b * 0.7)

func _process(delta):
	teleport_timer += delta
	
	if teleport_timer >= teleport_interval:
		teleport_timer = 0.0
		teleport_interval = randf_range(2.0, 3.5)
		teleport_to_random_position()

func teleport_to_random_position():
	var viewport_size = get_viewport_rect().size
	position.x = randf_range(50, viewport_size.x - 50)
	position.y = randf_range(50, viewport_size.y - 50)

func _on_body_entered(body):
	if body.name == "Player":
		# Criar um player temporário para garantir que o som toque
		var sound_player = AudioStreamPlayer.new()
		sound_player.stream = $CollisionSound.stream
		sound_player.volume_db = -2.0
		get_tree().root.add_child(sound_player)
		sound_player.play()
		
		emit_signal("bad_collected")
		queue_free()
		
		# Limpar o player após o som
		await sound_player.finished
		sound_player.queue_free()
