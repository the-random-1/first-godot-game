extends Area2D

@export var item: Global._ITEM_TYPES
@export var data: int
@export var quantity := 1
@onready var ui: CanvasLayer = $/root/Main/UI
var playercanpickup := false

var player: CharacterBody2D

func _ready() -> void:
	if !player:
		player = %Player
	
	$Sprite2D.scale = Vector2.ONE
	match item: # code for giving the item pickup its texture
		Global._ITEM_TYPES.WEAPON:
			$Sprite2D.texture = Global.texture
			$Sprite2D.region_enabled = true
			$Sprite2D.region_rect = Rect2(Global.weapon_constants[data].region.x, Global.weapon_constants[data].region.y, Global.weapon_constants[data].region.w, Global.weapon_constants[data].region.h)
			$CollisionShape2D.shape.set_size(Vector2(Global.weapon_constants[data].region.w, Global.weapon_constants[data].region.h))
			if Global.weapon_constants[data].region.h % 2 == 1:
				$Sprite2D.offset.y = -0.5
		Global._ITEM_TYPES.CHEST_KEY:
			$Sprite2D.texture = Global.chest_key_texture
			$Sprite2D.modulate = Color.from_hsv(data as float / 360, 1.0, 0.75)
		Global._ITEM_TYPES.KEY:
			$Sprite2D.texture = Global.key_texture
		Global._ITEM_TYPES.NOTHING:
			queue_free()
		_:
			pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") && playercanpickup && !player.inventoryisfull:
		player.add_item(item, data, quantity)
		
		if item == Global._ITEM_TYPES.WEAPON:
			if Global.currweapontype != Global._WEAPON_TYPES.NA:
				Global.place_item(Global._ITEM_TYPES.WEAPON, Global.currweapontype as int, global_position)
			Global.currweapontype = Global.selectedweapontype
			ui.switchequiptextvisibility(false, true)
		
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		playercanpickup = true
		
		if item == Global._ITEM_TYPES.WEAPON:
			ui.switchequiptextvisibility(true, true)
			Global.selectedweapontype = data as Global._WEAPON_TYPES
		else:
			ui.displaybottomtext("Click E to pick up")

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		playercanpickup = false
		
		if item == Global._ITEM_TYPES.WEAPON:
			ui.switchequiptextvisibility(false, false)
		else:
			ui.hidebottomtext()
