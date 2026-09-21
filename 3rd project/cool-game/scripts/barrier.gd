extends Node

@export var enemy_bounded_area: EnemyBoundedArea

func _ready() -> void:
	enemy_bounded_area.cleared.connect(toggleoff)

func toggleoff() -> void:
	for tilemaplayer in get_children():
		if tilemaplayer is DefaultTileMap:
			tilemaplayer.enabled = false
