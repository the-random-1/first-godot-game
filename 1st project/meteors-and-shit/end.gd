extends Control

var lvl: PackedScene = load("res://level.tscn")

func _ready() -> void:
	$VBoxContainer/Label2.text = "Score: " + str(Global.score)
	$lose.play()

func _process(_delta: float) -> void:
	if Input.is_action_pressed("lclick"):
		get_tree().change_scene_to_packed(lvl)
