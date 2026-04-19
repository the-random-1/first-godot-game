extends Enemy
class_name Slime

var wasinchase := false
var jumpattackdamage := 40.0
var jumpspeed := 225.0
var jumpheightmultiplier := 1.0
var jumplandradius := 40.0
var stuntime := 1.3

signal slimehit(dmg: float, stuntime: float)
signal slimejumphit(dmg: float, stuntime: float)

func changestate(newstate: _STATES) -> void:
	state = newstate
	var disablehitbox = func(): $CollisionShape2D.disabled = true
	match newstate:
		_STATES.IDLE:
			$AnimatedSprite2D.play("idle")
			forces[0] = Vector2.ZERO
		_STATES.WALK:
			$AnimatedSprite2D.play("walk")
		_STATES.CHASE:
			disablehitbox = func(): $CollisionShape2D.disabled = false
			$AnimatedSprite2D.play("chase")
		_STATES.STUNNED:
			$AnimatedSprite2D.play("stunned")
			forces[0] = Vector2.ZERO
		_STATES.JUMP:
			$AnimatedSprite2D.play("jump")
			forces[0] = Vector2.ZERO
	disablehitbox.call_deferred()

func _enemyinit() -> void:
	speed = 90.0
	max_health = 45.0
	health = max_health
	damage = 20.0
	kb = 1
	wander_time = Vector2(0.75, 2.0)
	m = 1.0
	rand = increaseMagnitude(rand)
	
	slimehit.connect(%Player._slimehit)
	slimejumphit.connect(%Player._slimejumphit)
	body_entered.connect(_on_body_entered)
	$StunTimer.timeout.connect(_on_stun_timer_timeout)
	$WaitForJumpTimer.timeout.connect(_attempt_jump)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if state == _STATES.CHASE:
			changestate(_STATES.STUNNED)
			$StunTimer.start()
			$WaitForJumpTimer.stop()
			slimehit.emit(damage, stuntime)
			applyforcetoplayer(0.25)

func _on_stun_timer_timeout() -> void:
	changestate(_STATES.IDLE)
	if isplayerinboundedarea():
		$WaitForJumpTimer.wait_time = 0.9 + randf_range(-0.25, 0.25)
		$WaitForJumpTimer.start()
		wasinchase = false

func _attempt_jump() -> void:
	var jumpdestination: Vector2 = %Player.global_position
	if isplayerinboundedarea() && global_position.distance_to(jumpdestination) > jumplandradius && jumpdestination.x != global_position.x:
		changestate(_STATES.JUMP)
		
		jumpdestination += %Player.forces[0] * 32
		jumpdestination += %Player.forces[0] * global_position.distance_to(jumpdestination) * 0.075
		
		var x1 := global_position.x
		var y1 := global_position.y
		var x2 := clampf(jumpdestination.x, bounded_area_x1, bounded_area_x2)
		var y2 := clampf(jumpdestination.y, bounded_area_y1, bounded_area_y2)
		var a := jumpheightmultiplier / absf(x1 - x2)
		var b := (y1 - y2 - a * (x1 ** 2 - x2 ** 2)) / (x1 - x2)

		var tween = get_tree().create_tween()
		tween.tween_method(calculateTrajectory.bind(a, b, signf(x2 - x1)), x1, x2, Global.calculate_integral(minf(x1, x2), maxf(x1, x2), func(e): return sqrt((2 * a * e + b) ** 2 + 1)) / jumpspeed)
		tween.tween_callback(landjump)
	else:
		$WaitForJumpTimer.wait_time = 0.9 + randf_range(-0.25, 0.25)
		$WaitForJumpTimer.start()

func landjump() -> void:
	changestate(_STATES.STUNNED)
	$StunTimer.start()
	if global_position.distance_to(%Player.global_position) < 12:
		applyforcetoplayer(0.25)
		slimejumphit.emit(jumpattackdamage, stuntime)

func calculateTrajectory(x: float, a: float, b: float, dir: float) -> void:
	var x1 := global_position.x
	var slope := 2 * a * x1 + b
	var den := sqrt(1 + slope ** 2)
	forces[0] = Vector2(1 / den, slope / den) * jumpspeed * dir

func _process(delta: float) -> void:
	move_with_velocity(delta, state != _STATES.JUMP)
	if isplayerinboundedarea():
		if state == _STATES.IDLE || state == _STATES.WALK:
			changestate(_STATES.CHASE)
			$WaitForJumpTimer.wait_time = 0.9 + randf_range(-0.25, 0.25) + rand * 0.5
			$WaitForJumpTimer.start()
	else:
		if state == _STATES.CHASE:
			$WaitForJumpTimer.stop()
			changestate(_STATES.IDLE)
	
	if state == _STATES.CHASE:
		destination = adjustChaseDestination(%Player.global_position, 30, 32)
		
		forces[0] = speed * global_position.direction_to(destination)
