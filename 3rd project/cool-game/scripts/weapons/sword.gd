extends Weapon

func ready() -> void:
	weapon_type = Global._WEAPON_TYPES.SWORD
	stats = weapon_stats.sword

func attack1() -> void:
	basic_swing(.2, .3, .1, 180, Tween.TRANS_EXPO)

func on_space() -> void:
	attack1()
