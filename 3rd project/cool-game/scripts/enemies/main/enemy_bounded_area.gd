extends ColorRect
class_name EnemyBoundedArea

var enemies := 0
signal cleared

func _ready() -> void:
	for enemy in get_children():
		if enemy is Enemy:
			enemy.bounded_area_x1 = global_position.x
			enemy.bounded_area_y1 = global_position.y
			enemy.bounded_area_x2 = global_position.x + size.x
			enemy.bounded_area_y2 = global_position.y + size.y
			enemy.favorite_area_x1 = enemy.bounded_area_x1 + (enemy.bounded_area_x2 - enemy.bounded_area_x1) * enemy.favorite_area_x1
			enemy.favorite_area_y1 = enemy.bounded_area_y1 + (enemy.bounded_area_y2 - enemy.bounded_area_y1) * enemy.favorite_area_y1
			enemy.favorite_area_x2 = enemy.bounded_area_x1 + (enemy.bounded_area_x2 - enemy.bounded_area_x1) * enemy.favorite_area_x2
			enemy.favorite_area_y2 = enemy.bounded_area_y1 + (enemy.bounded_area_y2 - enemy.bounded_area_y1) * enemy.favorite_area_y2
			
			enemy.death.connect(enemy_death)
			enemies += 1

func enemy_death() -> void:
	enemies -= 1
	if enemies == 0:
		cleared.emit()
