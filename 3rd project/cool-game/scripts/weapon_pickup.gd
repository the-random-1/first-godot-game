extends Area2D

@onready var weapon_pickups_ref: Node = $".."

@export var _weapon_type: Global._WEAPON_TYPES

signal playerfloatsover(visbility: bool)

func _ready() -> void:
	$Sprite2D.region_rect = Rect2(Global.weapon_constants[_weapon_type].region.x, Global.weapon_constants[_weapon_type].region.y, Global.weapon_constants[_weapon_type].region.w, Global.weapon_constants[_weapon_type].region.h)
	$CollisionShape2D.shape.set_size(Vector2(Global.weapon_constants[_weapon_type].region.w, Global.weapon_constants[_weapon_type].region.h))
	if Global.weapon_constants[_weapon_type].region.h % 2 == 1:
		$Sprite2D.offset.y = -0.5
	
	playerfloatsover.connect(%UI.switchequiptextvisibility)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		playerfloatsover.emit(true, true)
		Global.selectedweapontype = _weapon_type
		Global.selectedweaponref = self
func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		playerfloatsover.emit(false, false)
