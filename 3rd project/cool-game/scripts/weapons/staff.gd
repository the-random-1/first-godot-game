extends Weapon

func ready() -> void:
	weapon_type = Global._WEAPON_TYPES.STAFF
	stats = weapon_stats.staff

func attack1() -> void:
	pass

func on_space() -> void:
	attack1()
