extends Node2D

@export var SPEED := 75
var _direction := 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $RightRay.is_colliding():
		_direction = -1
		$AnimatedSprite2D.flip_h = true
	if $LeftRay.is_colliding():
		_direction = 1
		$AnimatedSprite2D.flip_h = false
	
	position.x += SPEED * _direction * delta
