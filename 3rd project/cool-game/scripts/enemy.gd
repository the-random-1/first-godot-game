extends Area2D
class_name Enemy

var bounded_area_x1: float
var bounded_area_y1: float
var bounded_area_x2: float
var bounded_area_y2: float
@export var favorite_area_x1: float
@export var favorite_area_y1: float
@export var favorite_area_x2: float
@export var favorite_area_y2: float
@export var favorite_area_chance := 0.0

enum _STATES {
	IDLE,
	WALK,
	CHASE,
	ATTACK,
	STUNNED,
	JUMP
}
var state := _STATES.IDLE
func changestate(newstate: _STATES) -> void:
	state = newstate

var destination: Vector2

var speed: float
var max_health: float
var health := max_health: set = set_health
var damage: float
var kb: float
var wander_time: Vector2
var m := 1.0
var rand := randf_range(-1.0, 1.0)

func set_health(newhealth: float) -> void:
	if newhealth <= 0.0:
		die()
	health = max(newhealth, 0.0)
	$HealthBar.set_healthbar(newhealth / max_health)
func change_health(diff: float) -> void:
	set_health(health + diff)

# Physics
var forces := {0: Vector2.ZERO}
var ignore_movement := false
func get_velocity_from_forces() -> Vector2:
	var sumofforces := Vector2.ZERO
	var i = 1
	var j = 0
	if ignore_movement:
		i = 0
	for force in forces.values():
		if j > 0:
			i = 1
		sumofforces += force * i
		j += 1
	return sumofforces
func apply_force(vel: Vector2, time: float, stun_movement: bool) -> void:
	ignore_movement = stun_movement
	var indextouse := 0
	var forcekeylist = forces.keys()
	forcekeylist.sort()
	for index in forcekeylist:
		if index != indextouse:
			break
		indextouse += 1
	forces[indextouse] = vel
	await get_tree().create_timer(time).timeout
	if stun_movement:
		ignore_movement = false
	forces.erase(indextouse)
func move_with_velocity(delta: float, clamp: bool = true) -> void:
	if clamp:
		global_position = (global_position + get_velocity_from_forces() * delta).clamp(Vector2(bounded_area_x1, bounded_area_y1), Vector2(bounded_area_x2, bounded_area_y2))
	else:
		global_position = (global_position + get_velocity_from_forces() * delta)
	if (forces[0].x < 0):
		$AnimatedSprite2D.flip_h = true
	elif (forces[0].x > 0):
		$AnimatedSprite2D.flip_h = false

func die() -> void:
	queue_free()

func _on_wander_timer_timeout() -> void:
	var time := randf_range(wander_time.x, wander_time.y)
	var newstate: _STATES = state
	
	if (state == _STATES.IDLE):
		destination.x = randf_range(bounded_area_x1, bounded_area_x2)
		destination.y = randf_range(bounded_area_y1, bounded_area_y2)
		time = global_position.distance_to(destination) / randf_range(.375 * speed, .875 * speed)
		forces[0] = Vector2((destination.x - global_position.x) / time, (destination.y - global_position.y) / time)
		newstate = _STATES.WALK
	
	if (state == _STATES.WALK):
		forces[0] = Vector2.ZERO
		newstate = _STATES.IDLE
	
	if state == _STATES.WALK || state == _STATES.IDLE:
		changestate(newstate)
	$WanderTimer.wait_time = time
	$WanderTimer.start()

func _on_area_entered(area: Area2D) -> void:
	if area is Weapon:
		var a = area.global_position.x
		var b = area.global_position.y
		var c = global_position.x
		var d = global_position.y
		if area.state == area._STATES.ATTACK1:
			apply_force(Vector2((c - a) / sqrt((d - b) ** 2 + (c - a) ** 2), (d - b) / sqrt((d - b) ** 2 + (c - a) ** 2)) * area.stats.attack1.kb / m, area.stats.attack1.kbt, true)
			change_health(-area.stats.attack1.damage)

func applyforcetoplayer(time: float) -> void:
	%Player.apply_force((%Player.global_position - global_position) * kb / %Player.global_position.distance_to(global_position), time)

func _ready() -> void:
	favorite_area_x1 = bounded_area_x1
	favorite_area_y1 = bounded_area_y1
	favorite_area_x2 = bounded_area_x2
	favorite_area_y2 = bounded_area_y2
	_enemyinit()
	area_entered.connect(_on_area_entered)
	$WanderTimer.timeout.connect(_on_wander_timer_timeout)
	$WanderTimer.wait_time = randf_range(wander_time.x, wander_time.y)
	$WanderTimer.start()

func _enemyinit() -> void:
	pass

func isplayerinboundedarea() -> bool:
	return %Player.global_position.x >= bounded_area_x1 && %Player.global_position.x <= bounded_area_x2 && %Player.global_position.y > bounded_area_y1 && %Player.global_position.y < bounded_area_y2

func adjustChaseDestination(origDest: Vector2, variance: int, cutoffdistance: float = 24.0) -> Vector2:
	if global_position.distance_to(origDest) > cutoffdistance:
		return origDest + Vector2(%Player.forces[0].y, %Player.forces[0].x) * variance * rand
	else:
		return origDest

func increaseMagnitude(val: float) -> float:
	return sqrt(abs(val)) * sign(val)

func decreaseMagnitude(val: float) -> float:
	return val ** 2 * sign(val)
