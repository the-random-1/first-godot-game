extends ColorRect

func _ready() -> void:
	for node in get_children():
		if (node is Enemy):
			node.bounded_area_x1 = global_position.x
			node.bounded_area_y1 = global_position.y
			node.bounded_area_x2 = global_position.x + size.x
			node.bounded_area_y2 = global_position.y + size.y
