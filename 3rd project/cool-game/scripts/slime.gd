extends Enemy

signal slimehit(dmg: float)

func changestate(newstate: _STATES) -> void:
	state = newstate
	match newstate:
		_STATES.IDLE:
			$AnimatedSprite2D.play("idle")
		_STATES.WALK:
			$AnimatedSprite2D.play("walk")
		_STATES.CHASE:
			$AnimatedSprite2D.play("chase")
		_STATES.JUMP:
			$AnimatedSprite2D.play("jump")

var jump_attack_damage := 40.0

func _enemyinit() -> void:
	speed = 80.0
	max_health = 45.0
	health = max_health
	damage = 20.0
	wander_time = Vector2(0.75, 2.0)
	m = 1.0
	rand = increaseMagnitude(rand)
	
	#body_entered.connect(_on_body_entered)
	$StunTimer.timeout.connect(_on_stun_timer_timeout)

func _on_stun_timer_timeout() -> void:
	pass
