extends Node2D

@onready var anim_player: AnimationPlayer = find_child("AnimationPlayer") as AnimationPlayer
@onready var sprite = $Sprite

var saved_coords: Vector2
var final_block_type: String
var level_ref: LevelBase # Ссылка на уровень, чтобы вернуть тайл

func start_jump(sheet_texture: Texture2D, tile_coords_in_atlas: Vector2i, texture_source: TileSetAtlasSource, cell_coords: Vector2, transform_to: String, level: LevelBase):
	sprite.region_enabled = true 
	sprite.texture = sheet_texture 
	sprite.region_rect = texture_source.get_tile_texture_region(tile_coords_in_atlas)
	
	# Запоминаем данные для финала
	saved_coords = cell_coords
	final_block_type = transform_to
	level_ref = level
	
	anim_player.play("bump") 
	await anim_player.animation_finished 
	
	# Анимация завершилась -> просим уровень вернуть постоянный тайл
	level_ref.spawn_final_tile(saved_coords, final_block_type)
	queue_free()
