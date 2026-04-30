extends Weapon

func ready() -> void:
	weapon_type = Global._WEAPON_TYPES.AXE
	stats = weapon_stats.axe

func attack1() -> void:
	basic_swing(.6, .4, .5, 250, Tween.TRANS_QUINT)

func on_space() -> void:
	attack1()
