extends Enemy
class_name RedGuy

func changestate(newstate: _STATES) -> void:
	state = newstate
	match newstate:
		_STATES.IDLE:
			$AnimatedSprite2D.play("idle")
		_STATES.WALK:
			$AnimatedSprite2D.play("walk")
		_STATES.CHASE:
			$AnimatedSprite2D.play("chase")
		_STATES.ATTACK:
			$AnimatedSprite2D.play("idle")

var wasinchase := false

signal redguyhit(dmg: float)

func _enemyinit() -> void:
	speed = 40.0
	max_health = 50.0
	health = max_health
	damage = 7.0
	wander_time = Vector2(2.0, 4.5)
	m = 1.0

	redguyhit.connect(%Player._redguyhit)
	body_entered.connect(_on_body_entered)
	$AttackDelay.timeout.connect(_on_attack_delay_timeout)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		changestate(_STATES.ATTACK)
		$AttackDelay.start()
		forces[0] = Vector2.ZERO

func _on_attack_delay_timeout():
	if global_position.distance_to(%Player.global_position) <= 16:
		redguyhit.emit(damage)
	for body in get_overlapping_bodies():
		if body.name == "Player":
			changestate(_STATES.ATTACK)
			$AttackDelay.start()
			forces[0] = Vector2.ZERO
			return true
	changestate(_STATES.IDLE)

func die() -> void:
	queue_free()

func process(delta: float) -> void:
	move_with_velocity(delta)
	if %Player.global_position.x >= bounded_area_x1 && %Player.global_position.x <= bounded_area_x2 && %Player.global_position.y > bounded_area_y1 && %Player.global_position.y < bounded_area_y2:
		if !(state == _STATES.CHASE || state == _STATES.ATTACK):
			changestate(_STATES.CHASE)
			wasinchase = true
	else:
		if wasinchase:
			wasinchase = false
			changestate(_STATES.IDLE)
			forces[0] = Vector2.ZERO
	if state == _STATES.CHASE:
		destination = adjustChaseDestination(%Player.global_position, 15)
		
		forces[0] = speed * global_position.direction_to(destination)
