extends Node2D

@onready var player = get_parent().get_node("Player")
var indicators = []
var max_indicators = 5

func _ready():
	# Criar pool de indicadores
	for i in range(max_indicators):
		var indicator = ColorRect.new()
		indicator.size = Vector2(20, 20)
		indicator.color = Color(0, 1, 0, 0.7)
		indicator.visible = false
		add_child(indicator)
		indicators.append(indicator)

func _process(_delta):
	if not player:
		return
	
	var viewport_size = get_viewport_rect().size
	var stars = get_tree().get_nodes_in_group("stars")
	var closest_stars = []
	
	# Encontrar as 5 estrelas mais próximas
	for star in stars:
		var distance = player.position.distance_to(star.position)
		closest_stars.append({"star": star, "distance": distance})
	
	closest_stars.sort_custom(func(a, b): return a.distance < b.distance)
	
	# Atualizar indicadores
	for i in range(max_indicators):
		if i < closest_stars.size():
			var star_data = closest_stars[i]
			var star = star_data.star
			var star_pos = star.position
			
			# Verificar se a estrela está fora da tela
			var is_offscreen = star_pos.x < 0 or star_pos.x > viewport_size.x or \
			                   star_pos.y < 0 or star_pos.y > viewport_size.y
			
			if is_offscreen:
				# Mostrar indicador na borda da tela
				var direction = (star_pos - player.position).normalized()
				var edge_pos = player.position + direction * 200
				
				# Limitar à borda da tela
				edge_pos.x = clamp(edge_pos.x, 20, viewport_size.x - 20)
				edge_pos.y = clamp(edge_pos.y, 20, viewport_size.y - 20)
				
				indicators[i].position = edge_pos - Vector2(10, 10)
				indicators[i].rotation = direction.angle() + PI/4
				indicators[i].visible = true
			else:
				indicators[i].visible = false
		else:
			indicators[i].visible = false
