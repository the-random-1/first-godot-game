extends StaticBody2D
class_name Chest

@export var item: Global._ITEM_TYPES
@export var data: int
var isplayertouching := false
var isopen := false

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player" && !isopen:
		isplayertouching = true
		displayhint()

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		isplayertouching = false
		%UI.hidebottomtext()

func displayhint():
	%UI.displaybottomtext("Click E to open chest")

func open() -> void:
	isopen = true
	$AnimatedSprite2D.play("open")
	%UI.hidebottomtext()
	await get_tree().create_timer(1.0).timeout
	Global.place_item(item, data, global_position)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") && isplayertouching && !isopen:
		open()
