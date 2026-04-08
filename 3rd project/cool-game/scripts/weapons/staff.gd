extends Weapon

func _ready() -> void:
	weapon_type = Global._WEAPON_TYPES.STAFF
	stats = weapon_stats.staff
	update_to_weapon_type()
