extends Node

var score := 0

func add_point():
	score += 1
	$"../Labels/Label2".text = "Congrats!\nYou found " + str(score) + "/5 coins."
