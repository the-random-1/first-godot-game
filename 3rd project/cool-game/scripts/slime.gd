extends Enemy
class_name Slime

var wasinchase := false
var jumpwindup := false
var jumpspeed := 20.0

signal slimehit(dmg: float)

func changestate(newstate: _STATES) -> void:
	state = newstate
	print(["idle", "walk", "chase", "", "stunned", "jump"][newstate])
	match newstate:
		_STATES.IDLE:
			$AnimatedSprite2D.play("idle")
			forces[0] = Vector2(0, 0)
		_STATES.WALK:
			$AnimatedSprite2D.play("walk")
		_STATES.CHASE:
			$AnimatedSprite2D.play("chase")
		_STATES.STUNNED:
			$AnimatedSprite2D.play("stunned")
		_STATES.JUMP:
			$AnimatedSprite2D.play("jump")
			forces[0] = Vector2(0, 0)

var jump_attack_damage := 40.0

func _enemyinit() -> void:
	speed = 70.0
	max_health = 45.0
	health = max_health
	damage = 20.0
	kb = 1
	wander_time = Vector2(0.75, 2.0)
	m = 1.0
	rand = increaseMagnitude(rand)
	
	slimehit.connect(%Player._slimehit)
	body_entered.connect(_on_body_entered)
	$StunTimer.timeout.connect(_on_stun_timer_timeout)
	$WaitForJumpTimer.timeout.connect(_attempt_jump)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if state == _STATES.CHASE:
			changestate(_STATES.STUNNED)
			$StunTimer.start()
			$WaitForJumpTimer.stop()
			slimehit.emit(damage)
			%Player.apply_force((%Player.global_position - global_position) * kb / %Player.global_position.distance_to(global_position), 0.25)
			forces[0] = Vector2(0, 0)
		elif state == _STATES.JUMP:
			pass

func _on_stun_timer_timeout() -> void:
	changestate(_STATES.IDLE)
	if isplayerinboundedarea():
		$WaitForJumpTimer.start()
		wasinchase = false

func _attempt_jump() -> void:
	if isplayerinboundedarea() && global_position.distance_to(%Player.global_position) > 40:
		jumpwindup = true
		changestate(_STATES.JUMP)
		destination = %Player.global_position
		# Math
		var x1 := global_position.x
		var y1 := global_position.y
		var x2 := destination.x
		var y2 := destination.y
		var a := 7.0 / absf(x1 - x2)
		var b := (y1 - y2 - a * (x1 ** 2 - x2 ** 2)) / (x1 - x2)
		var c := y1 - a * x1 ** 2 - b * x1
		print(global_position)
		print(destination)
		print(a)
		print(b)
		print(c)
		await get_tree().create_timer(2 / 3).timeout
		jumpwindup = false
		var tween = get_tree().create_tween()
		
		tween.tween_method(calculateTrajectory.bind(a, b, c), x1, x2, absf(x1 - x2) / jumpspeed)
		tween.tween_callback(func(): changestate(_STATES.IDLE)).set_delay(absf(x1 - x2) / jumpspeed)
	else:
		$WaitForJumpTimer.start()

func calculateTrajectory(x1: float, a: float, b: float, c: float) -> void:
	var slope := 2 * a * x1 + b
	print(slope)
	var den := sqrt(1 + slope ** 2)
	forces[0] = Vector2(1 / den, slope / den) * jumpspeed
	#global_position = Vector2(x1, a * (x1 ** 2) + b * x1 + c)

func _process(delta: float) -> void:
	#if state != _STATES.JUMP:
	move_with_velocity(delta, state != _STATES.JUMP)
	if isplayerinboundedarea():
		if state == _STATES.IDLE || state == _STATES.WALK:
			changestate(_STATES.CHASE)
			$WaitForJumpTimer.start()
	else:
		if state == _STATES.CHASE:
			$WaitForJumpTimer.stop()
			changestate(_STATES.IDLE)
	
	if state == _STATES.CHASE:
		destination = adjustChaseDestination(%Player.global_position, 7)
		
		var mult := speed / destination.distance_to(global_position)
		forces[0] = Vector2(destination.x - global_position.x, destination.y - global_position.y) * mult
	#elif state == _STATES.JUMP:
