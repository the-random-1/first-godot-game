extends Enemy
class_name GreenBoar

func changestate(newstate: _STATES) -> void:
	state = newstate
	match newstate:
		_STATES.IDLE:
			$AnimatedSprite2D.play("idle")
		_STATES.WALK:
			$AnimatedSprite2D.play("walk")
		_STATES.CHASE:
			$AnimatedSprite2D.play("chase")
		_STATES.STUNNED:
			$AnimatedSprite2D.play("stunned")

var wasinchase := false

signal greenboarhit(dmg: float)

func _enemyinit() -> void:
	speed = 70.0
	max_health = 60.0
	health = max_health
	damage = 15.0
	kb = 1.5
	wander_time = Vector2(1.0, 3.0)
	m = 1.0

	greenboarhit.connect(%Player._greenboarhit)
	body_entered.connect(_on_body_entered)
	$StunTimer.timeout.connect(_on_stun_timer_timeout)

func _on_body_entered(bodyc: Node2D) -> void:
	if bodyc.name == "Player" && state == _STATES.CHASE:
		changestate(_STATES.STUNNED)
		$StunTimer.start()
		greenboarhit.emit(damage)
		%Player.apply_force((%Player.global_position - global_position) * kb / %Player.global_position.distance_to(global_position), 0.25)
		forces[0] = Vector2(0, 0)

func _on_stun_timer_timeout() -> void:
	changestate(_STATES.IDLE)

func _process(delta: float) -> void:
	move_with_velocity(delta)
	if %Player.global_position.x >= bounded_area_x1 && %Player.global_position.x <= bounded_area_x2 && %Player.global_position.y > bounded_area_y1 && %Player.global_position.y < bounded_area_y2:
		if !(state == _STATES.CHASE || state == _STATES.STUNNED):
			changestate(_STATES.CHASE)
			wasinchase = true
	else:
		if wasinchase && state != _STATES.STUNNED:
			wasinchase = false
			changestate(_STATES.IDLE)
			forces[0] = Vector2(0, 0)
	if state == _STATES.CHASE:
		destination = adjustChaseDestination(%Player.global_position, 30)
		
		var mult := speed / destination.distance_to(global_position)
		forces[0] = Vector2(destination.x - global_position.x, destination.y - global_position.y) * mult
