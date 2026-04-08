extends Label

var h = 0

func flash() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(0.0, 0.67, 0.91), .3)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0), .8)
