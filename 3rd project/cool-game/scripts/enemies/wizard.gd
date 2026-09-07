extends Enemy
class_name Wizard

func changestate(newstate: _STATES) -> void:
	state = newstate
	match newstate:
		_STATES.IDLE:
			forces[0] = Vector2.ZERO
			$AnimatedSprite2D.play("idle")
		_STATES.WALK:
			$AnimatedSprite2D.play("walk")

func _enemyinit() -> void:
	speed = 75.0
	max_health = 50.0
	health = max_health
	damage = 25.0
	kb = 2.2
	wander_time = Vector2(1.0, 2.0)
	m = 1.0
	rand = increaseMagnitude(rand)
