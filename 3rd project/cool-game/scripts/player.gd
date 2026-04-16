extends CharacterBody2D

@onready var inventory_ref: Control = $"../UI/Inventory"

enum _STATES {
	IDLE,
	MOVING,
	PAUSE
}

var SPEED := 5000
var state := 0
var health := 100.0: set = set_health
func set_health(newhealth: float) -> void:
	health = maxf(newhealth, 0.0)
	$HealthBar.set_healthbar(newhealth / 100)
func change_health(diff: float) -> void:
	set_health(health + diff)
var forces := {0: Vector2(0, 0)}
func get_velocity_from_forces() -> Vector2:
	var sumofforces = Vector2(0, 0)
	for force in forces.values():
		sumofforces += force
	return sumofforces
func apply_force(vel: Vector2, time: float) -> void:
	var indextouse := 0
	var forcekeylist = forces.keys()
	forcekeylist.sort()
	for index in forcekeylist:
		if index != indextouse:
			break
		indextouse += 1
	forces[indextouse] = vel
	await get_tree().create_timer(time).timeout
	forces.erase(indextouse)
var inventory: Array[Dictionary] = []
var inventoryisopen := false
var inventoryisfull := false
var inventorysize := 6
func add_item(item: Global._ITEM_TYPES, data: int, amount: int = 1) -> void:
	if amount != 0:
		var hasItem := false
		var qIsZero := false
		for i in range(0, inventory.size()):
			if inventory[i]["item"] == item && inventory[i]["data"] == data:
				hasItem = true
				inventory[i]["quantity"] += amount
				if inventory[i]["quantity"] <= 0:
					qIsZero = true
		if !hasItem && inventory.size() < inventorysize:
			inventory.append({"item" = item, "quantity" = amount, "data" = data})
		if qIsZero:
			remove_item(item, data)
	inventoryisfull = inventory.size() == inventorysize
func remove_item(item: Global._ITEM_TYPES, data: int) -> void:
	for i in range(0, inventory.size()):
		if inventory[i]["item"] == item && inventory[i]["data"] == data:
			inventory.remove_at(i)
	inventoryisfull = inventory.size() == inventorysize
func has_item(item: Global._ITEM_TYPES, data: int, amount: int = 1) -> bool:
	for i in inventory:
		if i["item"] == item && i["data"] == data && i["quantity"] >= amount:
			return true
	return false

func change_state(new_state: _STATES):
	if new_state == _STATES.IDLE:
		$AnimatedSprite2D.play("idle")
	elif new_state == _STATES.MOVING:
		$AnimatedSprite2D.play("moving")
	elif new_state == _STATES.PAUSE:
		$AnimatedSprite2D.play("pause")

func _redguyhit(dmg: float) -> void:
	change_health(-dmg)
func _greenboarhit(dmg: float) -> void:
	change_health(-dmg)
func _pumpkindudehit(dmg: float) -> void:
	change_health(-dmg)
func _slimehit(dmg: float) -> void:
	change_health(-dmg)

func _ready() -> void:
	Global.player = self

func _physics_process(delta: float) -> void:
	forces[0] = round(Input.get_vector("move_left", "move_right", "move_up", "move_down"))
	velocity = SPEED * delta * get_velocity_from_forces()
	move_and_slide()
	
	if forces[0].x != 0 || forces[0].y != 0:
		change_state(_STATES.MOVING)
		if forces[0].x < 0:
			$AnimatedSprite2D.flip_h = true
		elif forces[0].x > 0:
			$AnimatedSprite2D.flip_h = false
	else:
		change_state(_STATES.IDLE)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") && Global.canpickupweapon:
		for child in get_children():
			if child is Weapon:
				child.queue_free()
		var weapon: PackedScene = load("res://scenes/weapons/" + ["sword", "longsword", "axe", "club", "staff"][Global.selectedweapontype] + ".tscn")
		var new_weapon = weapon.instantiate()
		add_child(new_weapon)

		if Global.currweaponref:
			Global.currweaponref.global_position = Global.selectedweaponref.global_position
			Global.currweaponref.visible = true
			Global.currweaponref.get_node("CollisionShape2D").disabled = false
		Global.selectedweaponref.visible = false
		Global.selectedweaponref.get_node("CollisionShape2D").disabled = true
		Global.currweapontype = Global.selectedweapontype
		Global.currweaponref = Global.selectedweaponref
		%UI.switchequiptextvisibility(false, true)

	if Input.is_action_just_pressed("inventory"):
		inventoryisopen = !inventoryisopen
		if inventoryisopen:
			%UI.reset_inventory_desc()
		inventory_ref.visible = inventoryisopen
