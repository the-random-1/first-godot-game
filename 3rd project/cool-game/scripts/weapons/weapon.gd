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

var state := _STATES.IDLE
func change_state(newstate: _STATES):
	state = newstate
	if newstate == _STATES.ATTACK1:
		collision_layer = 1
	else:
		collision_layer = 2

var weapon_type: Global._WEAPON_TYPES
var dir_of_aim: Vector2

func get_rot_from_dir() -> int:
	return [-30, 0, 30, -60, 0, 60, -135, 180, 135][[Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1), Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(-1, 1), Vector2(0, 1), Vector2(1, 1)].find(dir_of_aim)]

func _physics_process(_delta: float) -> void:
	if get_parent().forces[0].x != 0 || get_parent().forces[0].y != 0:
		dir_of_aim = get_parent().forces[0]
	
	if state == _STATES.IDLE && (get_parent().forces[0].x != 0 || get_parent().forces[0].y != 0):
		rotation_degrees = get_rot_from_dir()
		position = get_parent().forces[0] * Vector2(4.5, 3.5) + Vector2(0, 2)
	
		if get_parent().forces[0].y >= 0:
			z_index = 2
		else:
			z_index = 0

func update_to_weapon_type() -> void:
	$Sprite2D.region_rect = Rect2(Global.weapon_constants[weapon_type].region.x, Global.weapon_constants[weapon_type].region.y, Global.weapon_constants[weapon_type].region.w, Global.weapon_constants[weapon_type].region.h)
	$CollisionShape2D.shape.set_size(Vector2(Global.weapon_constants[weapon_type].region.w, Global.weapon_constants[weapon_type].region.h))
	$Sprite2D.position.y = Global.weapon_constants[weapon_type].region.h / -2 + 2
	$CollisionShape2D.position.y = Global.weapon_constants[weapon_type].region.h / -2 + 2

var attack1: Callable

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
