extends Weapon

func ready() -> void:
	weapon_type = Global._WEAPON_TYPES.AXE
	stats = weapon_stats.axe

func attack1() -> void:
	activestats = stats.attack1
	basic_swing(stats.attack1.timings[0], stats.attack1.timings[1], stats.attack1.timings[2], stats.attack1.angle, stats.attack1.transition_type)

func on_space() -> void:
	attack1()
