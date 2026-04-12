extends Enemy
class_name PumpkinDude

signal pumpkindudehit(dmg: float)

func changestate(newstate: _STATES) -> void:
	state = newstate
	match newstate:
		_STATES.IDLE:
			$AnimatedSprite2D.play("idle")
		_STATES.WALK:
			$AnimatedSprite2D.play("walk")
		_STATES.CHASE:
			$AnimatedSprite2D.play("chase")

var stunspeedmultiplier := 1.0

func _enemyinit() -> void:
	speed = 98.0
	max_health = 100.0
	health = max_health
	damage = 10.0
	kb = 2.2
	wander_time = Vector2(3.0, 5.0)
	m = 0.75
	rand = increaseMagnitude(rand)
	
	pumpkindudehit.connect(%Player._pumpkindudehit)
	body_entered.connect(_on_body_entered)
	$StunTimer.timeout.connect(_on_stun_timer_timeout)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" && state == _STATES.CHASE:
		pumpkindudehit.emit(damage)
		%Player.apply_force((%Player.global_position - global_position) * kb / %Player.global_position.distance_to(global_position), 0.2)
		stunspeedmultiplier = 0.3
		set_collision_mask_value(1, false)
		$StunTimer.start()

func _on_stun_timer_timeout() -> void:
	set_collision_mask_value(1, true)
	stunspeedmultiplier = 1

func _process(delta: float) -> void:
	move_with_velocity(delta)
	if %Player.global_position.x >= bounded_area_x1 && %Player.global_position.x <= bounded_area_x2 && %Player.global_position.y > bounded_area_y1 && %Player.global_position.y < bounded_area_y2:
		if state != _STATES.CHASE:
			changestate(_STATES.CHASE)
	else:
		if !(state == _STATES.IDLE || state == _STATES.WALK):
			changestate(_STATES.IDLE)
			forces[0] = Vector2(0, 0)
	if state == _STATES.CHASE:
		destination = adjustChaseDestination(%Player.global_position, 20)
		
		var time := speed / destination.distance_to(global_position)
		forces[0] = (destination - global_position) * time
