extends TileMapLayer
class_name DefaultTileMap

enum _WALL_TYPES {
	TOP,
	MIDDLE,
	BOTTOM
}

@export var _wall_type: _WALL_TYPES

func _ready() -> void:
	match _wall_type:
		_WALL_TYPES.TOP:
			z_index = 1
		_WALL_TYPES.MIDDLE:
			z_index = 3
		_WALL_TYPES.BOTTOM:
			z_index = 10
