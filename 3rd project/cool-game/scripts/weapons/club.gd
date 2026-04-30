extends Weapon

func ready() -> void:
	weapon_type = Global._WEAPON_TYPES.CLUB
	stats = weapon_stats.club

func attack1() -> void:
	basic_swing(.7, .3, .2, 200, Tween.TRANS_QUINT)

func on_space() -> void:
	attack1()
