extends Control

func reset_inventory_desc() -> void:
	$Main/PanelContainer/HBoxContainer/ItemDescriptions/VBoxContainer/Label.visible = false
	$Main/PanelContainer/HBoxContainer/ItemDescriptions/VBoxContainer/Label2.text = "Click on an item to read about it"
	$Main/PanelContainer/HBoxContainer/ItemDescriptions/VBoxContainer/Label2.visible = true

func change_desc(title: String, subtitle: String) -> void:
	$Main/PanelContainer/HBoxContainer/ItemDescriptions/VBoxContainer/Label.text = title
	$Main/PanelContainer/HBoxContainer/ItemDescriptions/VBoxContainer/Label.visible = true
	$Main/PanelContainer/HBoxContainer/ItemDescriptions/VBoxContainer/Label2.text = subtitle
	$Main/PanelContainer/HBoxContainer/ItemDescriptions/VBoxContainer/Label2.visible = true
