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
	speed = 120.0
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
			$AttackTimer.wait_time = 0.65
			$AttackTimer.start()
			changestate(_STATES.ATTACK)
			fireball()
	if state == _STATES.ATTACK:
		destination = global_position.clamp(Vector2(bounded_area_x1 + 8, bounded_area_y1 + 8), Vector2(bounded_area_x2 - 8, bounded_area_y2 - 8))
		if destination.distance_to(global_position) > 1:
			forces[0] = speed / 2 * global_position.direction_to(destination)
		else:
			forces[0] = Vector2.ZERO

func fireball() -> void:
	if $AttackTimer.time_left == 0 && state == _STATES.ATTACK:
		$AttackTimer.start()
		var new_fireball := Global.fireball.instantiate()
		new_fireball.sender = "wizard"
		new_fireball.damage = damage
		new_fireball.speed = 180.0
		new_fireball.direction = global_position.direction_to(%Player.global_position)
		new_fireball.player = %Player
		if global_position.x < %Player.global_position.x:
			fliph(false)
			new_fireball.global_position = global_position + Vector2(10, 0)
		else:
			fliph(true)
			new_fireball.global_position = global_position + Vector2(-10, 0)
		projectiles.add_child(new_fireball)

func on_attack_timer_timeout() -> void:
	if $AttackTimer.wait_time != 1.0:
		$AttackTimer.wait_time = 1.0
	fireball()

func isinreposarea(pos: Vector2) -> bool:
	return %Player.global_position.distance_to(pos) < min(min(bounded_area_x2 - bounded_area_x1, bounded_area_y2 - bounded_area_y1) / 2, 64)

func repos_destination() -> Vector2:
	var dir_to_player := global_position.direction_to(%Player.global_position)
	
	var new_dest: Vector2 = (global_position - dir_to_player * randf_range(56.0, 72.0)).clamp(Vector2(bounded_area_x1 + 8, bounded_area_y1 + 8), Vector2(bounded_area_x2 - 8, bounded_area_y2 - 8))
	if !((new_dest.x == bounded_area_x1 + 8 || new_dest.x == bounded_area_x2 - 8) && (new_dest.y == bounded_area_y1 + 8 || new_dest.y == bounded_area_y2 - 8)) && !isinreposarea(new_dest) && global_position.distance_to(new_dest) > 24:
		return new_dest
	
	new_dest = (global_position - dir_to_player * randf_range(24.0, 40.0)).clamp(Vector2(bounded_area_x1 + 8, bounded_area_y1 + 8), Vector2(bounded_area_x2 - 8, bounded_area_y2 - 8))
	if !((new_dest.x == bounded_area_x1 + 8 || new_dest.x == bounded_area_x2 - 8) && (new_dest.y == bounded_area_y1 + 8 || new_dest.y == bounded_area_y2 - 8)) && !isinreposarea(new_dest) && global_position.distance_to(new_dest) > 24:
		return new_dest
	
	new_dest = rand_point_in_area()
	var tries := 0
	var besttry := 1.0
	while dir_to_player.dot(global_position.direction_to(new_dest)) > 0.5 && tries < 15:
		var test_dest := rand_point_in_area().clamp(Vector2(bounded_area_x1 + 8, bounded_area_y1 + 8), Vector2(bounded_area_x2 - 8, bounded_area_y2 - 8))
		while isinreposarea(test_dest):
			test_dest = rand_point_in_area().clamp(Vector2(bounded_area_x1 + 8, bounded_area_y1 + 8), Vector2(bounded_area_x2 - 8, bounded_area_y2 - 8))
		var newtry := dir_to_player.dot(global_position.direction_to(test_dest))
		if newtry < besttry:
			new_dest = test_dest
			besttry = newtry
		
		tries += 1
	return new_dest
