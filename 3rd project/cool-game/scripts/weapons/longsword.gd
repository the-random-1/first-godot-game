extends Weapon

func ready() -> void:
	weapon_type = Global._WEAPON_TYPES.LONGSWORD
	stats = weapon_stats.longsword

func attack1() -> void:
	basic_swing(.21, .15, .08, 220, Tween.TRANS_EXPO)

func on_space() -> void:
	attack1()
