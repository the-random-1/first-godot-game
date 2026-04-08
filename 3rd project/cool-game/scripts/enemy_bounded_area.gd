extends Node2D

@export var bounded_area_p1: Vector2
@export var bounded_area_p2: Vector2

func _ready() -> void:
	for node in get_children():
		if (node is Enemy):
			node.bounded_area_x1 = bounded_area_p1.x
			node.bounded_area_y1 = bounded_area_p1.y
			node.bounded_area_x2 = bounded_area_p2.x
			node.bounded_area_y2 = bounded_area_p2.y
