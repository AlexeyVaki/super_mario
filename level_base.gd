extends Node2D

class_name LevelBase

@onready var phys_layer = $TileMaps/ContactLayer
@onready var bg_music = $BackgroundMusic
var block_manager = BlockReact.new()
const Jumping_Block_Scene = preload("res://jumping_block.tscn")

func player_hit_block(player, cell_coords:Vector2, actions: Array):
	if actions.is_empty():
		return 
	
	if "destroy" in actions:
		pass
	
	if "bump" in actions:
		var pixel_position = phys_layer.map_to_local(cell_coords)
		
		var source_id = phys_layer.get_cell_source_id(cell_coords)
		var tileset = phys_layer.tile_set
		var texture_source = tileset.get_source(source_id) as TileSetAtlasSource
		var tile_coords_in_atlas = phys_layer.get_cell_atlas_coords(cell_coords)
		
		# Вытаскиваем из BlockReact имя блока, в который текущий должен превратиться
		var tile_data = phys_layer.get_cell_tile_data(cell_coords)
		var current_block_type = tile_data.get_custom_data("block_name")
		var block_info = block_manager.Block_Data.get(current_block_type, {})
		var transform_to = block_info.get("transform_into", current_block_type) # Если нет трансформации, вернет сам себя
		
		# СПАВНИМ ПРЫГАЮЩИЙ АКТЕР (передаем ему данные и ссылку на self)
		var jumping_block = Jumping_Block_Scene.instantiate() 
		jumping_block.global_position = pixel_position        
		add_child(jumping_block)                             
		jumping_block.start_jump(texture_source.texture, tile_coords_in_atlas, texture_source, cell_coords, transform_to, self)
		
		# ЗАЩИТА ОТ БАГА: Мгновенно ставим невидимый твердый блок, пока играет анимация.
		# Вручную найди координаты твоего solid_block или sky в атласе и укажи вместо Vector2i(1, 1)
		# У него обязательно должна быть настроена физика маски в тайлсете!
		var solid_atlas_coords = Vector2i(10, 5) 
		phys_layer.set_cell(cell_coords, source_id, solid_atlas_coords)


# Эту функцию вызовет сам прыгающий блок, когда доиграет анимация подскока
func spawn_final_tile(cell_coords: Vector2, block_type: String):
	# Ищем в тайлсете координаты атласа для блока по его Custom Data имени
	var source_id = phys_layer.get_cell_source_id(cell_coords) # предполагаем, что источник тот же
	if source_id == -1: 
		source_id = 0 # дефолтный ID твоего основного листа тайлов
		
	var tileset = phys_layer.tile_set
	var texture_source = tileset.get_source(source_id) as TileSetAtlasSource
	
	# Динамически пробегаем по атласу, чтобы найти тайл с нужным block_name
	var target_atlas_coords = Vector2i(-1, -1)
	for i in range(texture_source.get_tiles_count()):
		var coords = texture_source.get_tile_id(i)
		var tile_data = texture_source.get_tile_data(coords, 0)
		if tile_data and tile_data.get_custom_data("block_name") == block_type:
			target_atlas_coords = coords
			break
			
	# Если нашли нужный блок в атласе — возвращаем его на карту навсегда
	if target_atlas_coords != Vector2i(-1, -1):
		phys_layer.set_cell(cell_coords, source_id, target_atlas_coords)
	else:
		# На случай, если что-то пошло не так, просто сотрем или оставим solid
		print("Предупреждение: не найден тайл для трансформации в ", block_type)


func check_player_hit(player: CharacterBody2D):
	var hit_point = Vector2.ZERO
	
	if player.ray_center.is_colliding():
		hit_point = player.ray_center.get_collision_point()
	elif player.ray_left.is_colliding():
		hit_point = player.ray_left.get_collision_point()
	elif player.ray_right.is_colliding():
		hit_point = player.ray_right.get_collision_point()
	
	if hit_point != Vector2.ZERO:
		hit_point.y -= 2
		var cell_coords = phys_layer.local_to_map(hit_point)
		print("\n=== [Level] Игрок стукнулся! Точка: ", hit_point, " Клетка сетки: ", cell_coords)
		
		var tile_data = phys_layer.get_cell_tile_data(cell_coords)
		if tile_data == null:
			print("=== [Level] ОШИБКА: Данные тайла NULL в клетке ", cell_coords)
			return
			
		var block_type = tile_data.get_custom_data("block_name")
		print("=== [Level] Имя блока из Custom Data: '", block_type, "'")
		
		var response = block_manager.trigger_block(player.player_state, block_type)
		print("=== [Level] Ответ от BlockManager: ", response)
		
		player_hit_block(player, cell_coords, response["action"])
