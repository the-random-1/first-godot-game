extends Weapon

func ready() -> void:
	weapon_type = Global._WEAPON_TYPES.CLUB
	stats = weapon_stats.club
	update_to_weapon_type()
	attack1 = Callable(self, "basic_swing").bind(.7, .3, .2, 200, Tween.TRANS_QUINT)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		attack1.call()
