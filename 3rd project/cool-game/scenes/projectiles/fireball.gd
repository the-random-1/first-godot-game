extends Projectile

var player: Player

signal fireballhit

func ready() -> void:
	if !speed:
		speed = 150.0
	
	fireballhit.connect(player._fireballhit)

func _on_body_entered(body: Node2D) -> void:
	if body is Player && sender != "Player":
		fireballhit.emit(damage)
		call_deferred("queue_free")
