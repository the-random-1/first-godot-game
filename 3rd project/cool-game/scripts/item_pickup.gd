extends Node

@export var item: Global._ITEM_TYPES
@export var data: int
@onready var ui: CanvasLayer = $/root/Main/UI
var playercanpickup := false

var player: CharacterBody2D

func _ready() -> void:
	if !player:
		player = %Player
	match item: # code for giving the item pickup its texture
		Global._ITEM_TYPES.CHEST_KEY:
			pass
		Global._ITEM_TYPES.KEY:
			pass
		Global._ITEM_TYPES.NOTHING:
			queue_free()
		_:
			pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") && playercanpickup && !player.inventoryisfull:
		player.add_item(item, data)
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		playercanpickup = true
		ui.displaybottomtext("Click E to pick up")

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		playercanpickup = false
		ui.hidebottomtext()
