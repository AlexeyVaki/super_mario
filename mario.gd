extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -175.0
const FALL_VELOCITY = 200.0
const ACCELERATION = 3.0
const start_jump_timer = 16
var jump_timer = start_jump_timer
var is_falling = false
var is_sliding = false
var has_hit_ceiling = false # Защита от многократных ударов в один прыжок

const mario_state_data = ["small", "big", "fire", "dead"]
var player_state = "small"

@onready var anim_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var level = get_parent() as LevelBase

@onready var ray_left = $block_detector/ray_left
@onready var ray_center = $block_detector/ray_center
@onready var ray_right = $block_detector/ray_right
@onready var jump_sound = $JumpSound

func _physics_process(delta: float) -> void:
	if player_state == "dead":
		return
	
	if is_on_floor():
		is_falling = false
		has_hit_ceiling = false # Сбрасываем флаг на земле
	
	if not is_on_floor():
		if is_on_ceiling():
			if not has_hit_ceiling: # Проверяем удар только ОДИН раз
				level.check_player_hit(self)
				has_hit_ceiling = true
		
		if not is_falling:
			if is_on_ceiling():
				velocity.y = 0
			if not is_on_ceiling() and jump_timer > 0 and Input.is_action_pressed("ui_accept") and velocity.y < 0:
				jump_timer -= 1
			else:
				jump_timer = start_jump_timer
				is_falling = true
		else:
			velocity += get_gravity() * delta
			if velocity.y > FALL_VELOCITY:
				velocity.y = FALL_VELOCITY

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sound.play()

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION/1.5)

	move_and_slide()
	
	update_animation(direction)
	

func death_sequence():
	player_state = "dead"
	
	collision_layer = 0
	collision_mask = 0
	
	if level:
		level.bg_music.stop()
		
	anim_player.play("dead")
	await anim_player.animation_finished
	
	get_tree().quit()
	
	
func update_animation(dir):
	if is_on_floor():
		if dir * velocity.x < 0:
			is_sliding = true
		elif dir * velocity.x > 0:
			is_sliding = false	 
			
		if velocity.x > 0:
			sprite.flip_h = false
		elif velocity.x < 0:
			sprite.flip_h = true
		
		if velocity.x == 0:
			anim_player.play("idle")
		elif is_sliding:
			anim_player.play("slide")
		else:
			anim_player.play("run")
	else:
		anim_player.play("jump")
