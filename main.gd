extends Node2D

@onready var player = $Player
@onready var coin_spawn_timer = $CoinSpawnTimer
@onready var bad_coin_spawn_timer = $BadCoinSpawnTimer
@onready var obstacle_spawn_timer = $ObstacleSpawnTimer
@onready var powerup_spawn_timer = $PowerUpSpawnTimer
@onready var golden_star_spawn_timer = $GoldenStarSpawnTimer
@onready var special_star_spawn_timer = $SpecialStarSpawnTimer
@onready var score_label = $CanvasLayer/Label
@onready var powerup_label = $CanvasLayer/PowerUpLabel
@onready var start_label = $CanvasLayer/StartLabel
@onready var instructions_label = $CanvasLayer/InstructionsLabel
@onready var lives_container = $CanvasLayer/LivesContainer

var score = 0
var lives = 5
var coin_scene = preload("res://coin.tscn")
var star_scene = preload("res://star.tscn")
var bad_coin_scene = preload("res://bad_coin.tscn")
var obstacle_scene = preload("res://obstacle.tscn")
var powerup_scene = preload("res://powerup.tscn")

var game_started = false

# Power-up states
var speed_multiplier = 1.0
var double_points = false
var has_shield = false
var powerup_timers = {}

func _ready():
	randomize()
	coin_spawn_timer.connect("timeout", Callable(self, "_spawn_coin"))
	bad_coin_spawn_timer.connect("timeout", Callable(self, "_spawn_bad_coin"))
	obstacle_spawn_timer.connect("timeout", Callable(self, "_spawn_obstacle"))
	powerup_spawn_timer.connect("timeout", Callable(self, "_spawn_powerup"))
	golden_star_spawn_timer.connect("timeout", Callable(self, "_spawn_golden_star"))
	special_star_spawn_timer.connect("timeout", Callable(self, "_spawn_special_star"))
	
	# Pausar todos os timers no início
	coin_spawn_timer.stop()
	bad_coin_spawn_timer.stop()
	obstacle_spawn_timer.stop()
	powerup_spawn_timer.stop()
	golden_star_spawn_timer.stop()
	special_star_spawn_timer.stop()
	
	# Esconder labels de jogo
	score_label.visible = false
	powerup_label.visible = false
	lives_container.visible = false
	
	# Aplicar multiplicador de velocidade ao player
	player.speed = 200.0 * speed_multiplier
	# Desabilitar controles do player
	player.set_physics_process(false)

func _process(_delta):
	if not game_started and Input.is_action_just_pressed("ui_accept"):
		start_game()

func start_game():
	game_started = true
	start_label.visible = false
	instructions_label.visible = false
	score_label.visible = true
	powerup_label.visible = true
	lives_container.visible = true
	score_label.text = "Pontuação: 0"
	
	# Iniciar timers
	coin_spawn_timer.start()
	bad_coin_spawn_timer.start()
	obstacle_spawn_timer.start()
	powerup_spawn_timer.start()
	golden_star_spawn_timer.start()
	special_star_spawn_timer.start()
	
	# Habilitar controles do player
	player.set_physics_process(true)

func _spawn_coin():
	var coin = coin_scene.instantiate()
	var viewport_size = get_viewport_rect().size
	coin.position = Vector2(
		randf_range(50, viewport_size.x - 50),
		randf_range(50, viewport_size.y - 50)
	)
	coin.connect("collected", Callable(self, "_on_coin_collected"))
	add_child(coin)

func _spawn_golden_star():
	var star = star_scene.instantiate()
	star.type = 1  # GOLDEN
	var viewport_size = get_viewport_rect().size
	star.position = Vector2(
		randf_range(50, viewport_size.x - 50),
		randf_range(50, viewport_size.y - 50)
	)
	star.connect("collected", Callable(self, "_on_star_collected"))
	add_child(star)

func _spawn_special_star():
	var star = star_scene.instantiate()
	star.type = 2  # SPECIAL
	var viewport_size = get_viewport_rect().size
	star.position = Vector2(
		randf_range(50, viewport_size.x - 50),
		randf_range(50, viewport_size.y - 50)
	)
	star.connect("collected", Callable(self, "_on_star_collected"))
	add_child(star)

func _spawn_powerup():
	var powerup = powerup_scene.instantiate()
	powerup.type = randi() % 3  # Random type
	var viewport_size = get_viewport_rect().size
	powerup.position = Vector2(
		randf_range(50, viewport_size.x - 50),
		randf_range(50, viewport_size.y - 50)
	)
	powerup.connect("collected", Callable(self, "_on_powerup_collected"))
	add_child(powerup)

func _spawn_bad_coin():
	var bad_coin = bad_coin_scene.instantiate()
	var viewport_size = get_viewport_rect().size
	bad_coin.position = Vector2(
		randf_range(50, viewport_size.x - 50),
		randf_range(50, viewport_size.y - 50)
	)
	bad_coin.connect("bad_collected", Callable(self, "_on_bad_coin_collected"))
	add_child(bad_coin)
func _on_coin_collected():
	var points = 1
	if double_points:
		points *= 2
	score += points
	score_label.text = "Pontuação: %d" % score
	
	if score >= 25:
		score_label.text = "Você venceu!"
		coin_spawn_timer.stop()
		bad_coin_spawn_timer.stop()
		golden_star_spawn_timer.stop()
		special_star_spawn_timer.stop()
		powerup_spawn_timer.stop()
		obstacle_spawn_timer.stop()

func _on_star_collected(points):
	if double_points:
		points *= 2
	score += points
	score_label.text = "Pontuação: %d" % score
	
	if score >= 25:
		score_label.text = "Você venceu!"
		coin_spawn_timer.stop()
		bad_coin_spawn_timer.stop()
		golden_star_spawn_timer.stop()
		special_star_spawn_timer.stop()
		powerup_spawn_timer.stop()
		obstacle_spawn_timer.stop()

func _on_powerup_collected(type):
	match type:
		0:  # SPEED
			speed_multiplier = 1.5
			player.speed = 200.0 * speed_multiplier
			powerup_label.text = "⚡ Velocidade Aumentada!"
			_start_powerup_timer("speed", 5.0)
		1:  # SHIELD
			has_shield = true
			player.modulate = Color(0.5, 0.8, 1, 1)
			powerup_label.text = "🛡️ Escudo Ativo!"
			_start_powerup_timer("shield", 8.0)
		2:  # DOUBLE_POINTS
			double_points = true
			powerup_label.text = "⭐ Pontos em Dobro!"
			_start_powerup_timer("double", 10.0)

func _start_powerup_timer(type_name, duration):
	if powerup_timers.has(type_name) and powerup_timers[type_name]:
		powerup_timers[type_name].queue_free()
	
	var timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_powerup_timeout").bind(type_name))
	add_child(timer)
	timer.start()
	powerup_timers[type_name] = timer

func _on_powerup_timeout(type_name):
	match type_name:
		"speed":
			speed_multiplier = 1.0
			player.speed = 200.0
		"shield":
			has_shield = false
			player.modulate = Color(1, 1, 1, 1)
		"double":
			double_points = false
	
	powerup_label.text = ""
	if powerup_timers.has(type_name):
		powerup_timers.erase(type_name)

func _on_bad_coin_collected():
	if has_shield:
		# Escudo absorve o dano
		powerup_label.text = "🛡️ Escudo bloqueou!"
		return
	
	lives -= 1
	update_lives_display()
	
	if lives <= 0:
		# Game Over
		score_label.text = "GAME OVER! Pontuação Final: %d" % score
		coin_spawn_timer.stop()
		bad_coin_spawn_timer.stop()
		golden_star_spawn_timer.stop()
		special_star_spawn_timer.stop()
		powerup_spawn_timer.stop()
		obstacle_spawn_timer.stop()
		
		# Desabilitar controles do player
		player.set_physics_process(false)
		player.visible = false

func update_lives_display():
	for i in range(5):
		var life_icon = lives_container.get_child(i)
		life_icon.visible = i < lives

func _spawn_obstacle():
	var obstacle = obstacle_scene.instantiate()
	var viewport_size = get_viewport_rect().size
	obstacle.position = Vector2(
		randf_range(100, viewport_size.x - 100),
		randf_range(100, viewport_size.y - 100)
	)
	add_child(obstacle)
