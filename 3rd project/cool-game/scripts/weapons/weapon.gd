extends Area2D
class_name Weapon

enum _STATES {
	IDLE,
	ATTACK1
}

signal state_change(state: _STATES)

var weapon_stats := {
	"sword": {
		"attack1": {
			"damage": 25,
			"force": 1.2,
			"kb": 90,
			"kbt": .25,
			"angle": 180,
			"timings": [.2, .3, .1],
			"transition_type": Tween.TransitionType.TRANS_EXPO
		}
	},
	"longsword": {
		"attack1": {
			"damage": 20,
			"force": 0.8,
			"kb": 57,
			"kbt": .2,
			"angle": 220,
			"timings": [.21, .15, .08],
			"transition_type": Tween.TransitionType.TRANS_EXPO
		}
	},
	"axe": {
		"attack1": {
			"damage": 50,
			"force": 2.5,
			"kb": 150,
			"kbt": .275,
			"angle": 250,
			"timings": [.48, .25, .3],
			"transition_type": Tween.TransitionType.TRANS_QUINT
		}
	},
	"club": {
		"attack1": {
			"damage": 45,
			"force": 2.0,
			"kb": 200,
			"kbt": .18,
			"angle": 200,
			"timings": [.45, .25, .17],
			"transition_type": Tween.TransitionType.TRANS_QUINT
		}
	},
	"staff": {
		"attack1": {
			"damage": 20,
			"force": 1.0,
			"kb": 20,
			"kbt": .3
		}
	},
}
var stats: Dictionary
var activestats: Dictionary
var player: Node2D

var state := _STATES.IDLE
func change_state(newstate: _STATES) -> void:
	state = newstate
	state_change.emit(state)

var hitbox_size: Vector2

var weapon_type: Global._WEAPON_TYPES
var dir_of_aim: Vector2

func get_rot_from_dir() -> float:
	var vector := player.global_position.direction_to(get_global_mouse_position())
	var angle := asin(vector.x)
	if vector.y > 0:
		angle = PI - angle
	return rad_to_deg(angle)

func _physics_process(_delta: float) -> void:
	dir_of_aim = player.global_position.direction_to(get_global_mouse_position())
	
	if state == _STATES.IDLE && !player.stunned:
		rotation_degrees = get_rot_from_dir()
		position = dir_of_aim * Vector2(4.5, 4.5) + Vector2(0, 2)
	
		if dir_of_aim.y >= 0:
			z_index = 2
		else:
			z_index = 0

var tween: Tween
func reset_tween() -> void:
	if tween:
		tween.kill()
	tween = get_tree().create_tween()

func _ready() -> void:
	player = get_parent()
	#hitbox_size = $CollisionShape2D.size
	area_entered.connect(on_area_entered)
	ready()

func ready() -> void:
	pass

func attack1() -> void:
	pass

func on_space() -> void:
	pass

func basic_swing(d1: float, d2: float, d3: float, slash_angle: float, trans: Tween.TransitionType) -> void:
	if state == _STATES.IDLE:
		change_state(_STATES.ATTACK1)
		$CollisionShape2D.disabled = true
		
		var attack1_rot_dir := 1
		if dir_of_aim.x < 0:
			attack1_rot_dir = -1
		
		reset_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(trans)
		
		tween.tween_property(self, "rotation_degrees", -slash_angle / 2 * attack1_rot_dir, d1).as_relative()
		tween.tween_callback(func() -> void: $CollisionShape2D.set_deferred("disabled", false))
		tween.tween_property(self, "rotation_degrees", slash_angle * attack1_rot_dir, d2).as_relative()
		tween.tween_callback(func() -> void: $CollisionShape2D.set_deferred("disabled", true); change_state(_STATES.IDLE))
		tween.tween_property(self, "rotation_degrees", -slash_angle / 2 * attack1_rot_dir, d3).as_relative()

func on_area_entered(area: Area2D) -> void:
	if area is EnemyWeapon:
		if area.weapon_state == EnemyWeapon._WEAPON_STATES.PARRY:
			if tween:
				tween.kill()
			change_state(_STATES.IDLE)
			$CollisionShape2D.set_deferred("disabled", true)
