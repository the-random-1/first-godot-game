extends Node2D
class_name Door

var isplayertouching := false
var isopen := false

func _ready() -> void:
	$Area2D.connect("body_entered", _on_body_entered)
	$Area2D.connect("body_exited", _on_body_exited)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") && isplayertouching:
		doorinteract()
	if global_position.y <= %Player.global_position.y + 10:
		z_index = 4
	else:
		z_index = 10

func doorinteract() -> void:
	toggledoor()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		isplayertouching = true
		displayhint()

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		isplayertouching = false
		%UI.hidebottomtext()

func displayhint() -> void:
	if isopen:
		%UI.displaybottomtext("Click E to close door")
	else:
		%UI.displaybottomtext("Click E to open door")

func toggledoor() -> void:
	isopen = !isopen
	$TileMapLayerClosedDoor.visible = !isopen
	$TileMapLayerClosedDoor.collision_enabled = !isopen
	$TileMapLayerOpenDoor.visible = isopen
	$TileMapLayerOpenDoor.collision_enabled = isopen
	displayhint()
