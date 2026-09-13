extends Area2D

var speed: float
var destination: Vector2
var destroyed_by_walls := true

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	global_position += speed * global_position.direction_to(destination) * delta

func _on_body_entered(body: Node2D) -> void:
	if body is TileMapLayer && destroyed_by_walls:
		queue_free()
	if body is Player:
		pass
