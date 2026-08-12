extends Enemy
class_name DeathKnight

signal deathknighthit(dmg: float)

enum _WEAPON_STATES {
	IDLE,
	ATTACK,
	PARRY
}

var weapon_state := _WEAPON_STATES.IDLE

func changestate(newstate: _STATES) -> void:
	state = newstate
	match newstate:
		_STATES.IDLE:
			$AnimatedSprite2D.play("idle")
		_STATES.WALK:
			$AnimatedSprite2D.play("walk")
		_STATES.CHASE:
			$AnimatedSprite2D.play("chase")
		_STATES.PAUSE:
			$AnimatedSprite2D.play("pause")
		_STATES.ATTACK:
			$AnimatedSprite2D.play("attack")
		_STATES.STUNNED:
			$AnimatedSprite2D.play("stunned")
func changeweaponstate(newstate: _WEAPON_STATES) -> void:
	weapon_state = newstate
	$EnemyWeapon.weapon_state = newstate

func fliph(face_left: bool) -> void:
	$AnimatedSprite2D.flip_h = face_left
	if state == _STATES.IDLE || state == _STATES.WALK:
		$EnemyWeapon.rotation_degrees = 0
		$EnemyWeapon.position.y = 7
		if face_left:
			$EnemyWeapon.position.x = -9
		else:
			$EnemyWeapon.position.x = 9

var tween: Tween
func reset_tween() -> void:
	if tween:
		tween.kill()
	tween = get_tree().create_tween()

func _enemyinit() -> void:
	speed = 85.0
	max_health = 150.0
	health = max_health
	damage = 20.0
	kb = 1.5
	wander_time = Vector2(2.0, 3.5)
	m = 2.0
	
	deathknighthit.connect(%Player._deathknighthit)
	$EnemyWeapon.body_entered.connect(_on_body_entered_weapon)
	$EnemyWeapon.area_entered.connect(_on_area_entered_weapon)
	$ParryDetection.area_entered.connect(_on_parry_detected)
	$AttackTimer.timeout.connect(_on_attack_timer_timeout)
	$ParryTimer.timeout.connect(_on_parry_timer_timeout)

func process(delta: float) -> void:
	move_with_velocity(delta)
	if isplayerinboundedarea():
		if state == _STATES.IDLE || state == _STATES.WALK:
			changestate(_STATES.CHASE)
		if state == _STATES.PAUSE:
			forces[0] = Vector2.ZERO
		if state == _STATES.CHASE:
			speed = 85.0
		
		var playerDist := global_position.distance_to(%Player.global_position)
		if state != _STATES.ATTACK:
			if playerDist < 20.0:
				changestate(_STATES.PAUSE)
			elif playerDist > 30.0:
				changestate(_STATES.CHASE)
		
		if weapon_state == _WEAPON_STATES.IDLE:
			var dir := global_position.direction_to(%Player.global_position)
			$EnemyWeapon.position = dir * 7 + Vector2(0, 2)
			$EnemyWeapon.rotation_degrees = get_rot_from_dir(dir)
			
			if playerDist < 50.0 && %Player.isAttacking() && $ParryTimer.time_left == 0 && state != _STATES.ATTACK:
				parry(0.13)
			if playerDist < 40.0 && !%Player.isAttacking() && $AttackTimer.time_left == 0:
				attack()
	else:
		if !(state == _STATES.IDLE || state == _STATES.WALK):
			changestate(_STATES.IDLE)
	if state == _STATES.CHASE || state == _STATES.ATTACK:
		destination = adjustChaseDestination(%Player.global_position, 8)
		
		forces[0] = speed * global_position.direction_to(destination)

func _on_parry_detected(area: Area2D) -> void:
	if area is Weapon && state == _STATES.CHASE:
		if $ParryTimer.time_left == 0:
			parry(0.07, true)
		else:
			if state == _STATES.CHASE:
				reverse_movement(0.175, 0.35)

func _on_body_entered_weapon(body: Node2D) -> void:
	if body is Player && weapon_state == _WEAPON_STATES.ATTACK:
		deathknighthit.emit(damage)
		%Player.apply_force(global_position.direction_to(%Player.global_position) * kb, 0.2)
		changestate(_STATES.PAUSE)

func _on_area_entered_weapon(area: Area2D) -> void:
	if area is Weapon:
		if area.activestats.force >= 1.5:
			$ParryTimer.wait_time = 1.25 * area.activestats.force * 1.25
		else:
			$ParryTimer.wait_time = 1.25

func attack() -> void:
	$AttackTimer.start()
	changestate(_STATES.ATTACK)
	changeweaponstate(_WEAPON_STATES.ATTACK)
	
	reset_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	
	var attack_rot_dir := 1
	if $EnemyWeapon.rotation_degrees > 90 && $EnemyWeapon.rotation_degrees < 270:
		attack_rot_dir = -1
	
	tween.tween_property($EnemyWeapon, "rotation_degrees", -100 * attack_rot_dir, 0.2).as_relative()
	tween.tween_callback(func() -> void: speed = 150.0)
	tween.tween_property($EnemyWeapon, "rotation_degrees", 200 * attack_rot_dir, 0.25).as_relative()
	tween.tween_callback(func() -> void: speed = 35.0; reverse_movement(0.4))
	tween.tween_property($EnemyWeapon, "rotation_degrees", -100 * attack_rot_dir, 0.23).as_relative()
	tween.tween_callback(func() -> void: changeweaponstate(_WEAPON_STATES.IDLE); changestate(_STATES.CHASE))

func parry(hold_time: float = 0.07, tryattack: bool = false) -> void:
	$ParryTimer.start()
	changeweaponstate(_WEAPON_STATES.PARRY)
	
	reset_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART).set_parallel(true)
	
	var dir_to_player: Vector2 = $EnemyWeapon.global_position.direction_to(%Player.global_position)
	
	tween.tween_property($EnemyWeapon, "rotation_degrees", -110, 0.2).as_relative()
	tween.tween_property($EnemyWeapon, "position", Vector2(sin($EnemyWeapon.rotation + PI * 0.5), -cos($EnemyWeapon.rotation + PI * 0.5)) * 5.5 + dir_to_player * 5, 0.2).as_relative()
	
	await get_tree().create_timer(0.2 + hold_time).timeout
	changeweaponstate(_WEAPON_STATES.IDLE)
	if tryattack && $AttackTimer.time_left == 0:
		attack()

func _on_attack_timer_timeout() -> void:
	pass

func _on_parry_timer_timeout() -> void:
	pass

func chill() -> void:
	if state == _STATES.CHASE:
			changestate(_STATES.IDLE)
			$EnemyWeapon.rotation_degrees = 0
			if forces[0].x <= 0:
				$EnemyWeapon.position = Vector2(-9, 7)
			else:
				$EnemyWeapon.position = Vector2(9, 7)
			forces[0] = Vector2.ZERO
			$WanderTimer.wait_time = randf_range(wander_time.x, wander_time.y) * 0.2
			$WanderTimer.start()
