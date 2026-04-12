extends Weapon

func ready() -> void:
	weapon_type = Global._WEAPON_TYPES.AXE
	stats = weapon_stats.axe
	update_to_weapon_type()
	attack1 = Callable(self, "basic_swing").bind(.6, .4, .5, 250, Tween.TRANS_QUINT)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		attack1.call()
