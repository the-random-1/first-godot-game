extends Weapon

func ready() -> void:
	weapon_type = Global._WEAPON_TYPES.LONGSWORD
	stats = weapon_stats.longsword
	attack1 = Callable(self, "basic_swing").bind(.25, .2, .1, 220, Tween.TRANS_EXPO)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		attack1.call()
