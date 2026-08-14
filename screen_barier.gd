extends Camera2D

func _ready() -> void:
	# Получаем размер игрового окна из настроек проекта
	var screen_size = get_viewport_rect().size
	var half_width = screen_size.x / 2
	var height = screen_size.y
	
	# Создаем физическое твердое тело, которое будет двигаться вместе с камерой
	var static_body = StaticBody2D.new()
	add_child(static_body)
	
	# 1. СОЗДАЕМ ЛЕВУЮ СТЕНУ
	var left_collision = CollisionShape2D.new()
	var left_shape = RectangleShape2D.new()
	left_shape.size = Vector2(20, height * 2) # Высокая стена с запасом
	left_collision.shape = left_shape
	# Ставим её ровно на левую границу кадра
	left_collision.position = Vector2(-half_width - 10, 0) 
	static_body.add_child(left_collision)
	
	# 2. СОЗДАЕМ ПРАВУЮ СТЕНУ
	var right_collision = CollisionShape2D.new()
	var right_shape = RectangleShape2D.new()
	right_shape.size = Vector2(20, height * 2)
	right_collision.shape = right_shape
	# Ставим её ровно на правую границу кадра
	right_collision.position = Vector2(half_width + 10, 0)
	static_body.add_child(right_collision)
