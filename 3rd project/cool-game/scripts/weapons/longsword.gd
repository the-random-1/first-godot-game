extends Weapon

func ready() -> void:
	weapon_type = Global._WEAPON_TYPES.LONGSWORD
	stats = weapon_stats.longsword

func attack1() -> void:
	basic_swing(.25, .2, .1, 220, Tween.TRANS_EXPO)

func on_space() -> void:
	attack1()
