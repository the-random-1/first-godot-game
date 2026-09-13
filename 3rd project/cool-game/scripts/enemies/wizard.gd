extends Enemy
class_name Wizard

@onready var projectiles: Node = $"/root/Main/Projectiles"

func changestate(newstate: _STATES) -> void:
	state = newstate
	match newstate:
		_STATES.IDLE:
			forces[0] = Vector2.ZERO
			$AnimatedSprite2D.play("idle")
		_STATES.WALK:
			$AnimatedSprite2D.play("walk")
		_STATES.ATTACK:
			forces[0] = Vector2.ZERO
			$AnimatedSprite2D.play("attack")
		_STATES.REPOSITION:
			$AnimatedSprite2D.play("run")

func _enemyinit() -> void:
	speed = 90.0
	max_health = 50.0
	health = max_health
	damage = 25.0
	kb = 2.2
	wander_time = Vector2(1.0, 2.0)
	m = 1.0
	rand = increaseMagnitude(rand)
	
	$AttackTimer.timeout.connect(on_attack_timer_timeout)

func process(delta: float) -> void:
	move_with_velocity(delta)
	if isplayerinboundedarea():
		if state != _STATES.REPOSITION && isinreposarea(global_position) && $RepositionTimer.time_left == 0:
			changestate(_STATES.REPOSITION)
			destination = repos_destination()
		if (state == _STATES.IDLE || state == _STATES.WALK) && $AttackTimer.time_left == 0:
			changestate(_STATES.ATTACK)
			fireball()
	else:
		if !(state == _STATES.IDLE || state == _STATES.WALK):
			changestate(_STATES.IDLE)
	if state == _STATES.REPOSITION:
		forces[0] = speed * global_position.direction_to(destination)
		if global_position.distance_to(destination) < 5:
			$RepositionTimer.start()
			changestate(_STATES.ATTACK)
			fireball()

func fireball() -> void:
	if $AttackTimer.time_left == 0 && state == _STATES.ATTACK:
		$AttackTimer.start()
		var new_fireball := Global.fireball.instantiate()
		if global_position.x < %Player.global_position.x:
			fliph(false)
			new_fireball.global_position = global_position + Vector2(8, 0)
		else:
			fliph(true)
			new_fireball.global_position = global_position + Vector2(-8, 0)
		projectiles.add_child(new_fireball)
		print("attack!!!")

func on_attack_timer_timeout() -> void:
	fireball()

func isinreposarea(pos: Vector2) -> bool:
	return %Player.global_position.distance_to(pos) < min(bounded_area_x2 - bounded_area_x1, bounded_area_y2 - bounded_area_y1) / 2

func repos_destination() -> Vector2:
	var new_dest := Vector2(randf_range(bounded_area_x1, bounded_area_x2), randf_range(bounded_area_y1, bounded_area_y2))
	while isinreposarea(new_dest):
		new_dest = Vector2(randf_range(bounded_area_x1, bounded_area_x2), randf_range(bounded_area_y1, bounded_area_y2))
	return new_dest
