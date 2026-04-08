extends CanvasLayer


func set_score(newtext) -> void:
	$MarginContainer/ScoreLabel.text = str(newtext)
