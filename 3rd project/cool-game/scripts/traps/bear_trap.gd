extends Area2D

var enabled := true

func _ready() -> void:
	$AnimatedSprite2D.visible = false
	body_entered.connect(tripped)
	$AnimatedSprite2D.animation_finished.connect(animation_finished)
	$ResetTimer.timeout.connect(reset)

func tripped(body: Node2D) -> void:
	if body is Player && enabled:
		enabled = false
		$AnimatedSprite2D.visible = true
		z_index = 11
		$AnimatedSprite2D.play("close")
		%Player.beartrap(global_position)

func animation_finished() -> void:
	if $AnimatedSprite2D.animation == "close":
		$ResetTimer.start()
	elif $AnimatedSprite2D.animation == "open":
		$AnimatedSprite2D.visible = false
		enabled = true

func reset() -> void:
		z_index = 4
		$AnimatedSprite2D.play("open")
