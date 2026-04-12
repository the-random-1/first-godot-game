extends Weapon

func ready() -> void:
	weapon_type = Global._WEAPON_TYPES.SWORD
	stats = weapon_stats.sword
	update_to_weapon_type()
	attack1 = Callable(self, "basic_swing").bind(.2, .3, .1, 180, Tween.TRANS_EXPO)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		attack1.call()
