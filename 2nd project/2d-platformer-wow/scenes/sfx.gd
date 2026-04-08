extends Node

func play_sound(sound_name) -> void:
	if sound_name == "coin":
		$coin.play()
