extends Area2D
class_name Projectile

var speed: float
var direction: Vector2
var destroyed_by_walls := true

var sender: String

var damage: float

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	$WallHitBox.body_entered.connect(_on_wall_hit)
	ready()

func ready() -> void:
	pass

func _process(delta: float) -> void:
	global_position += speed * direction * delta
	process(delta)

func process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	pass

func _on_wall_hit(body: Node2D) -> void:
	if body is TileMapLayer && destroyed_by_walls:
		call_deferred("queue_free")
