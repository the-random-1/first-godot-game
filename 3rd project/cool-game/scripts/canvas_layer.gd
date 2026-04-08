extends CanvasLayer

func switchequiptextvisibility(visbility: bool, canpickupweaponafter: bool) -> void:
	$MarginContainer/EToEquipText.text = "Click E to equip"
	$MarginContainer.visible = visbility
	Global.canpickupweapon = canpickupweaponafter

func displaybottomtext(text: String) -> void:
	$MarginContainer/EToEquipText.text = text
	$MarginContainer.visible = true

func hidebottomtext() -> void:
	$MarginContainer.visible = false

func reset_inventory_desc() -> void:
	$Inventory.reset_inventory_desc()

func change_desc(title: String, subtitle: String) -> void:
	$Inventory.change_desc(title, subtitle)
