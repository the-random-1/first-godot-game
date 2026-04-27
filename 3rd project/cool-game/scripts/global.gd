extends Node

func calculate_integral(lowerbound: float, upperbound: float, f: Callable, stepsize: float = 0.1) -> float:
	var area := 0.0
	for i in range(lowerbound / stepsize, upperbound / stepsize + 1):
		area += f.call(i * stepsize) * stepsize
	return area

const weapon_constants := [
	{ # sword
		"region": {
			"x": 339,
			"y": 10,
			"w": 10,
			"h": 21
		}
	},
	{ # longsword
		"region": {
			"x": 293,
			"y": 66,
			"w": 6,
			"h": 29
		}
	},
	{ # axe
		"region": {
			"x": 288,
			"y": 167,
			"w": 16,
			"h": 24
		}
	},
	{ # club
		"region": {
			"x": 323,
			"y": 41,
			"w": 10,
			"h": 22
		}
	},
	{ # staff
		"region": {
			"x": 340,
			"y": 128,
			"w": 8,
			"h": 31
		}
	}
]

enum _WEAPON_TYPES {
	SWORD,
	LONGSWORD,
	AXE,
	CLUB,
	STAFF,
	NA
}

enum _ITEM_TYPES {
	NOTHING,
	WEAPON,
	CHEST_KEY,
	KEY
}

const _KEY_COLOR_HUES := {
	"red": 350,
	"blue": 192
}

var canpickupweapon := false
var selectedweapontype: _WEAPON_TYPES = _WEAPON_TYPES.NA
var currweapontype: _WEAPON_TYPES = _WEAPON_TYPES.NA

var player: CharacterBody2D

func place_item(item: _ITEM_TYPES, data: int, pos: Vector2) -> void:
	var itempickupscene: PackedScene = load("res://scenes/item_pickup.tscn")
	var newitem := itempickupscene.instantiate()
	newitem.item = item
	newitem.data = data
	newitem.global_position = pos
	newitem.player = player
	$/root/Main/ItemPickups.add_child(newitem)
