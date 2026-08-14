extends CharacterBody2D

var speed = -30
const statuses = ["alive", "dead"]
var status = "alive"

@onready var anim_pleer = $Sprite2D/AnimationPlayer

func _physics_process(delta: float) -> void:
	if is_on_wall():
		speed = -speed
	velocity.x = speed
	move_and_slide()
	update_animation(status)
	
	
func update_animation(status):
	if status == "alive":
		anim_pleer.play("walk")
	elif status == "dead":
		anim_pleer.play("dead")
