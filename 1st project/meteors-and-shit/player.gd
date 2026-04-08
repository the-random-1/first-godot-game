extends CharacterBody2D

var health := 100.0

var rot_min := 0.0
var rot_d := 40.0
var rot_max := 80.0

var rot := rot_d
var rot_goal := rot_d

signal shoot(pos)

func _process(delta: float) -> void:
	var dir = Input.get_vector("left", "right", "up", "down")
	velocity = dir * 500
	move_and_slide()
	
	if dir.x > 0:
		rot_goal = rot_max
	elif dir.x < 0:
		rot_goal = rot_min
	else:
		rot_goal = rot_d
	
	if absf(rot - rot_goal) > 1:
		rot += dir.x * 300 * delta
		if dir.x == 0:
			rot += ((rot_goal - rot) / absf(rot_goal - rot)) * 300 * delta
		rot = clamp(rot, rot_min, rot_max)
	else:
		rot = rot_goal
	
	$CollisionPolygon2D.rotation_degrees = rot - rot_d
	$Sprite2D.rotation_degrees = rot - rot_d
	
	if Input.is_action_just_pressed("shoot"):
		shoot.emit(global_position)
