extends Area2D

signal collected

var teleport_timer = 0.0
var teleport_interval = 3.0

func _ready():
	add_to_group("stars")
	connect("body_entered", Callable(self, "_on_body_entered"))
	teleport_interval = randf_range(2.5, 4.0)

func _process(delta):
	teleport_timer += delta
	
	if teleport_timer >= teleport_interval:
		teleport_timer = 0.0
		teleport_interval = randf_range(2.5, 4.0)
		teleport_to_random_position()

func teleport_to_random_position():
	var viewport_size = get_viewport_rect().size
	position.x = randf_range(50, viewport_size.x - 50)
	position.y = randf_range(50, viewport_size.y - 50)

func _on_body_entered(body):
	if body.name == "Player":
		var sound_player = AudioStreamPlayer.new()
		sound_player.stream = $CoinSound.stream
		sound_player.volume_db = -5.0
		get_tree().root.add_child(sound_player)
		sound_player.play()
		emit_signal("collected")
		queue_free()
		await sound_player.finished
		sound_player.queue_free()
