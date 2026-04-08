extends Node2D

var healthqueue := [-1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0]

func _ready() -> void:
	$Timer.timeout.connect(_update_health_queue)

func _update_health_queue() -> void:
	if healthqueue[0] != -1:
		$Red.size.x = healthqueue[0] * 10
	healthqueue.pop_front()
	healthqueue.push_back(-1.0)

func set_healthbar(health: float) -> void:
	$Green.size.x = health * 10
	healthqueue[-1] = health
