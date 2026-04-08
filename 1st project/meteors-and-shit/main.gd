extends Node2D

var meteor_bp: PackedScene = load("res://meteor.tscn")
var laser_bp: PackedScene = load("res://laser.tscn")
var can_shoot := true
var shoot_cooldown := 0.2

func _ready() -> void:
	$ShootCooldown.wait_time = shoot_cooldown
	Global.score = 0


func _on_timer_timeout() -> void:
	var new_meteor = meteor_bp.instantiate()
	$Meteors.add_child(new_meteor)
	new_meteor.connect("player_got_hit", _on_player_got_hit)
	new_meteor.connect("scoresound", func() -> void: $score10.play())

func _on_player_got_hit(stre: float) -> void:
	$Player.health -= stre * 5
	$Player/Node2D/ColorRect2.scale.x = max($Player.health / 100, 0)
	if $Player.health <= 0:
		get_tree().change_scene_to_file("res://end.tscn")

func _on_player_shoot(pos: Variant) -> void:
	if can_shoot:
		#can_shoot = false
		var new_laser = laser_bp.instantiate()
		new_laser.position = pos
		$Lasers.add_child(new_laser)
		$ShootCooldown.start()
		$Audio/laser.play()

func _on_shoot_cooldown_timeout() -> void:
	can_shoot = true
