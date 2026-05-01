extends Area2D
class_name Weapon

enum _STATES {
	IDLE,
	ATTACK1,
	ATTACK1C
}

var weapon_stats = {
	"sword": {
		"attack1": {
			"damage": 25,
			"kb": 90,
			"kbt": .25
		}
	},
	"longsword": {
		"attack1": {
			"damage": 20,
			"kb": 65,
			"kbt": .2
		}
	},
	"axe": {
		"attack1": {
			"damage": 40,
			"kb": 150,
			"kbt": .275
		}
	},
	"club": {
		"attack1": {
			"damage": 45,
			"kb": 200,
			"kbt": .18
		}
	},
	"staff": {
		"attack1": {
			"damage": 20,
			"kb": 20,
			"kbt": .3
		}
	},
}
var stats: Dictionary
var player: Node2D

var state := _STATES.IDLE
func change_state(newstate: _STATES):
	state = newstate
	if newstate == _STATES.ATTACK1:
		collision_layer = 1
	else:
		collision_layer = 2


var weapon_type: Global._WEAPON_TYPES
var dir_of_aim: Vector2

func get_rot_from_dir() -> float:
	var vector = get_mouse_angle()
	var angle = asin(vector.x)
	if vector.y > 0:
		angle = PI - angle
	return rad_to_deg(angle)

func get_mouse_angle() -> Vector2:
	var mouse_pos = get_global_mouse_position()
	var player_pos = player.global_position
	var mouse_distance := mouse_pos.distance_to(player_pos)
	return (mouse_pos - player_pos) / mouse_distance

func _physics_process(_delta: float) -> void:
	dir_of_aim = get_mouse_angle()
	
	if state == _STATES.IDLE && !player.stunned:
		rotation_degrees = get_rot_from_dir()
		position = dir_of_aim * Vector2(4.5, 4.5) + Vector2(0, 2)
	
		if dir_of_aim.y >= 0:
			z_index = 2
		else:
			z_index = 0

func _ready() -> void:
	player = get_parent() 
	ready()

func ready() -> void:
	pass

func attack1() -> void:
	pass

func on_space() -> void:
	pass

func basic_swing(d1: float, d2: float, d3: float, slash_angle: float, trans: Tween.TransitionType):
	if state == _STATES.IDLE:
		change_state(_STATES.ATTACK1C)
		
		var attack1_rot_dir := 1
		if dir_of_aim.x < 0:
			attack1_rot_dir = -1
		
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(trans)
		
		tween.tween_property(self, "rotation_degrees", -slash_angle / 2 * attack1_rot_dir, d1).as_relative()
		tween.tween_callback(func(): change_state(_STATES.ATTACK1))
		tween.tween_property(self, "rotation_degrees", slash_angle * attack1_rot_dir, d2).as_relative()
		tween.tween_callback(func(): change_state(_STATES.ATTACK1C))
		tween.tween_property(self, "rotation_degrees", -slash_angle / 2 * attack1_rot_dir, d3).as_relative()
		tween.tween_callback(func(): change_state(_STATES.IDLE))
