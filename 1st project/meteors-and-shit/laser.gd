extends Area2D

var laser_speed := 1500

func _process(delta: float) -> void:
	position.y -= laser_speed * delta
	if position.y < -50:
		queue_free()
