extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		%GameManager.add_point()
		SFX.play_sound("coin")
		queue_free()
