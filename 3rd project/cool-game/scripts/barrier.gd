extends StaticBody2D


func disable() -> void:
	visible = false
	$CollisionShape2D.disabled = true

func enable() -> void:
	visible = true
	$CollisionShape2D.disabled = false

func disable_forever() -> void:
	call_deferred("queue_free")
