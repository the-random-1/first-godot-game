extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$Timer.start()
		body.get_node("CollisionShape2D").queue_free()


func _on_timer_timeout() -> void:
	get_tree().reload_current_scene.call_deferred()
