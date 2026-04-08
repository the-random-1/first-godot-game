extends Chest

@export var keyhole_color: String
var keyhole_hue_code: int
var locked := true

func _ready() -> void:
	keyhole_hue_code = Global._KEY_COLOR_HUES[keyhole_color]
	$Keyhole/KeyholeRect.color = Color.from_hsv(float(keyhole_hue_code) / 360, 1.0, 0.52)
	$Keyhole/KeyholeRect2.color = Color.from_hsv(float(keyhole_hue_code) / 360, 1.0, 0.26)
	$Keyhole/KeyholeRect3.color = Color.from_hsv(float(keyhole_hue_code) / 360, 1.0, 0.26)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		if isplayertouching && !isopen:
			if locked:
				if %Player.has_item(Global._ITEM_TYPES.CHEST_KEY, keyhole_hue_code):
					unlock()
			else:
				open()

func unlock() -> void:
	%Player.add_item(Global._ITEM_TYPES.CHEST_KEY, keyhole_hue_code, -1)
	locked = false
	$Keyhole.queue_free()
	displayhint()

func displayhint():
	if locked:
		if %Player.has_item(Global._ITEM_TYPES.CHEST_KEY, keyhole_hue_code):
			%UI.displaybottomtext("Click E to unlock chest")
		else:
			%UI.displaybottomtext("Chest requires a " + keyhole_color.to_lower() + " key to open")
	else:
		%UI.displaybottomtext("Click E to open chest")
