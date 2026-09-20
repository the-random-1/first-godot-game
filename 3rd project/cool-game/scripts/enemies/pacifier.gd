extends Enemy

func changestate(newstate: _STATES) -> void:
	state = newstate
	match newstate:
		_STATES.IDLE:
			$AnimatedSprite2D.play("idle")
			forces[0] = Vector2.ZERO
		_STATES.WALK:
			$AnimatedSprite2D.play("walk")
		_STATES.CHASE:
			$AnimatedSprite2D.play("chase")
		_STATES.STUNNED:
			$AnimatedSprite2D.play("stunned")

signal pacifierhit(dmg: float, stuntime: float)

var stuntime: float

func _enemyinit() -> void:
	speed = 125.0
	max_health = 75.0
	health = max_health
	damage = 10.0
	kb = 1.5
	stuntime = 2.5 + rand * 0.4
	wander_time = Vector2(0.5, 1.0)
	m = 0.3

	pacifierhit.connect(%Player._pacifierhit)
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is Weapon && state != _STATES.STUNNED:
		stun(stuntime * 0.65)

func _on_body_entered(body: Node2D) -> void:
	if body is Player && state == _STATES.CHASE:
		apply_force(body.global_position.direction_to(global_position) * 175, 0.25, true)
		stun(stuntime - 0.2)
		pacifierhit.emit(damage, stuntime)
		applyforcetoplayer(0.25)


func process_state(delta: float) -> void:
	if state != _STATES.STUNNED:
		if isplayerinboundedarea():
			if state != _STATES.CHASE:
				changestate(_STATES.CHASE)
		else:
			if state == _STATES.CHASE:
				changestate(_STATES.IDLE)
		if state == _STATES.CHASE:
			destination = adjustChaseDestination(%Player.global_position, 5)
			
			forces[0] = speed * global_position.direction_to(destination)
