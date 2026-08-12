extends Enemy
class_name DeathKnight

func changestate(newstate: _STATES) -> void:
	state = newstate
	match newstate:
		_STATES.IDLE:
			$AnimatedSprite2D.play("idle")
		_STATES.WALK:
			$AnimatedSprite2D.play("walk")
		_STATES.CHASE:
			$AnimatedSprite2D.play("chase")

func fliph(face_left: bool) -> void:
	$AnimatedSprite2D.flip_h = face_left
	if state == _STATES.IDLE || state == _STATES.WALK:
		if face_left:
			$EnemyWeapon.position.x = -9
		else:
			$EnemyWeapon.position.x = 9

func _enemyinit() -> void:
	speed = 70.0
	max_health = 100.0
	health = max_health
	damage = 15.0
	wander_time = Vector2(2.0, 3.5)
	m = 1.25

func process(delta: float) -> void:
	move_with_velocity(delta)
	if isplayerinboundedarea():
		if state != _STATES.CHASE:
			changestate(_STATES.CHASE)
		
		var dir := global_position.direction_to(%Player.global_position)
		$EnemyWeapon.position = (dir + Vector2(0, 5 / 7)) * 7
		$EnemyWeapon.rotation_degrees = get_rot_from_dir(dir)
	else:
		if !(state == _STATES.IDLE || state == _STATES.WALK):
			changestate(_STATES.IDLE)
			forces[0] = Vector2.ZERO
	if state == _STATES.CHASE:
		destination = adjustChaseDestination(%Player.global_position, 8)
		
		forces[0] = speed * global_position.direction_to(destination)
