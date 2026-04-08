extends Area2D

var movement_dir = Vector2(randf_range(-.7, .7), randf_range(.8, 1))
var rot_dir = sqrt(randf_range(-1.0, 1.0))
var strength = randi_range(1, 10)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(randf_range(0, get_viewport().get_visible_rect().size[0]) * 1.2, randf_range(-100, -200))
	rotation_degrees = randi_range(0, 360)
	$Sprite2D.texture = load("res://assets/PNG/Meteors/meteorBrown_" + str(["big1", "big2", "big3", "big4", "med1", "med3", "small1", "small2", "tiny1", "tiny2"][10 - strength]) + ".png")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += movement_dir * 600 * delta
	rotation_degrees += rot_dir * 90 * delta
	if position.y > get_viewport().get_visible_rect().size[1] + 100:
		queue_free()

signal player_got_hit(stre: float)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.name == "Player":
		player_got_hit.emit(float(strength))

signal scoresound
func _on_area_entered(area: Area2D) -> void:
	if area.name == "laser":
		Global.score += 1
		if Global.score % 10 == 0:
			scoresound.emit()
			get_tree().call_group("scorelabel", "flash")
		get_tree().call_group("ui", "set_score", Global.score)
		queue_free()
