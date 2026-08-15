extends CharacterBody2D

var speed = -30
const statuses = ["alive", "dead"]
var status = "alive"

@onready var anim_pleer = $Sprite2D/AnimationPlayer
@onready var sprite = $Sprite2D 

# Ссылка на форму коллизии самой Гумбы
@onready var collision_shape = $CollisionShape2D

func _physics_process(delta: float) -> void:
	if status == "dead":
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_on_wall():
		change_direction()

	velocity.x = speed
	move_and_slide()
	
	# 1. РАЗВОРOT ОТ ДРУГИХ ГУМБ
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.name.contains("Goomba") and collider != self:
			change_direction()
			break

	# 2. ПРОВЕРКА УРОНА И ПРЫЖКА СВЕРХУ (По геометрии)
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var mario = players[0]
		
		# Проверяем, что Марио жив
		if mario.has_method("death_sequence") and mario.player_state != "dead":
			var mario_shape = mario.get_node("CollisionShape2D") as CollisionShape2D
			
			if mario_shape and collision_shape:
				# Получаем точные мировые прямоугольники хитбоксов Марио и Гумбы
				var mario_rect = mario_shape.shape.get_rect()
				mario_rect.position += mario_shape.global_position
				
				var goomba_rect = collision_shape.shape.get_rect()
				goomba_rect.position += collision_shape.global_position
				
				# Небольшое виртуальное расширение на 0.1 пикселя для четкого стыка
				var expanded_goomba_rect = goomba_rect.grow(0.1)
				
				# Если хитбоксы соприкоснулись
				if mario_rect.intersects(expanded_goomba_rect):
					
					# ПРОВЕРКА НА ПРЫЖОК СВЕРХУ: Марио летит вниз и его центр выше центра Гумбы
					if mario.velocity.y > 0 and mario.global_position.y < global_position.y:
						print("Марио раздавил Гумбу сверху!")
						mario.velocity.y = -175.0 # Марио делает отскок вверх
						goomba_death() # Запускаем смерть Гумбы
					else:
						# Во всех остальных случаях (бег спереди, сзади в спину) Марио умирает
						print("Марио коснулся Гумбы и умер!")
						mario.death_sequence()

	update_animation(status)

func update_animation(current_status):
	if current_status == "alive":
		anim_pleer.play("walk")
	elif current_status == "dead":
		anim_pleer.play("dead")

func change_direction():
	speed = -speed
	if speed > 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

# Функция смерти Гумбы
func goomba_death():
	status = "dead"
	velocity = Vector2.ZERO # Останавливаем её на месте
	
	# Полностью отключаем коллизии тела, 
	# чтобы труп Гумбы не мешал Марио лететь дальше и больше никого не убивал
	collision_layer = 0
	collision_mask = 0
	
	# Включаем анимацию сплющивания
	anim_pleer.play("dead")
	await anim_pleer.animation_finished
	queue_free()
