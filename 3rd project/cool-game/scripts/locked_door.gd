extends Door

@export var keyhole_code := 0
var locked := true

func doorinteract() -> void:
	if locked:
		if %Player.has_item(Global._ITEM_TYPES.KEY, keyhole_code):
			unlock()
	else:
		toggledoor()

func unlock() -> void:
	%Player.add_item(Global._ITEM_TYPES.KEY, keyhole_code, -1)
	locked = false
	$Lock.queue_free()
	displayhint()

func displayhint() -> void:
	if locked:
		if %Player.has_item(Global._ITEM_TYPES.KEY, keyhole_code):
			%UI.displaybottomtext("Click E to unlock door")
		else:
			%UI.displaybottomtext("Door is locked")
	else:
		if isopen:
			%UI.displaybottomtext("Click E to close door")
		else:
			%UI.displaybottomtext("Click E to open door")
