extends CharacterBody2D
class_name Player

@onready var inventory_ref: Control = $"../UI/Inventory"

enum _STATES {
	IDLE,
	MOVING,
	PAUSE
}

signal space

var SPEED := 5000
var state := _STATES.IDLE
var weapon_state: Weapon._STATES
var health := 100.0: set = set_health
func set_health(newhealth: float) -> void:
	health = maxf(newhealth, 0.0)
	$HealthBar.set_healthbar(newhealth / 100)
func change_health(diff: float) -> void:
	set_health(health + diff)

var forces := {0: Vector2.ZERO}
func get_velocity_from_forces() -> Vector2:
	var sumofforces := Vector2.ZERO
	for force: Vector2 in forces.values():
		if !(force == forces[0] && stunned):
			sumofforces += force
	return sumofforces
func apply_force(vel: Vector2, time: float) -> void:
	var indextouse := 0
	var forcekeylist := forces.keys()
	forcekeylist.sort()
	for index: int in forcekeylist:
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
	if amount != 0 && item != Global._ITEM_TYPES.NOTHING:
		var nowinventoryisfull := true
		var firstemptyindex: int = -1
		var emptyindexes: int = 0
		var alreadydone := false
		for i in range(inventorysize - 1, -1, -1):
			if inventory[i].item == item && inventory[i].data == data:
				inventory[i].quantity += amount
				if inventory[i].quantity == 0:
					remove_item(item, data)
				alreadydone = true
			if inventory[i].item == Global._ITEM_TYPES.NOTHING:
				firstemptyindex = i
				nowinventoryisfull = false
				emptyindexes += 1
			
		if firstemptyindex != -1 && !alreadydone:
			inventory[firstemptyindex].item = item
			inventory[firstemptyindex].data = data
			inventory[firstemptyindex].quantity = amount
			if emptyindexes == 1:
				nowinventoryisfull = true
		inventoryisfull = nowinventoryisfull
func remove_item(item: Global._ITEM_TYPES, data: int) -> void:
	inventoryisfull = true
	for i in range(0, inventorysize):
		if inventory[i].item == item && inventory[i].data == data:
			inventory[i].item = Global._ITEM_TYPES.NOTHING
			inventory[i].quantity = 0
			inventory[i].data = 0
		if inventory[i].item == Global._ITEM_TYPES.NOTHING:
			inventoryisfull = false
func has_item(item: Global._ITEM_TYPES, data: int, amount: int = 1) -> bool:
	for inventoryitem in inventory:
		if inventoryitem.item == item && inventoryitem.data == data && inventoryitem.quantity >= amount:
			return true
	return false

var stunned := false

func change_state(new_state: _STATES) -> void:
	if state != new_state:
		state = new_state
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
func _slimehit(dmg: float, stuntime: float) -> void:
	change_health(-dmg)
	stun(stuntime)
func _slimejumphit(dmg: float, stuntime: float) -> void:
	change_health(-dmg)
	stun(stuntime)
func _deathknighthit(dmg: float) -> void:
	change_health(-dmg)

func _ready() -> void:
	Global.player = self
	$StunTimer.timeout.connect(stun_timer_timeout)
	$PracticalVelocityTimer.timeout.connect(update_practical_velocity)
	
	inventory.resize(6)
	inventory.assign(inventory.map(func(e: Dictionary) -> Dictionary: return {"item": Global._ITEM_TYPES.NOTHING, "quantity": 0, "data": 0}))
	#Engine.time_scale = 0.33

func _physics_process(delta: float) -> void:
	if !stunned:
		forces[0] = round(Input.get_vector("move_left", "move_right", "move_up", "move_down"))
	velocity = SPEED * delta * get_velocity_from_forces()
	move_and_slide()
	
	if !stunned:
		if forces[0].x != 0 || forces[0].y != 0:
			change_state(_STATES.MOVING)
			if forces[0].x < 0:
				$AnimatedSprite2D.flip_h = true
			elif forces[0].x > 0:
				$AnimatedSprite2D.flip_h = false
		else:
			change_state(_STATES.IDLE)
	else:
		change_state(_STATES.PAUSE)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("space"):
		if !stunned:
			space.emit()
	
	if Input.is_action_just_pressed("interact") && Global.canpickupweapon:
		for child in get_children():
			if child is Weapon:
				child.queue_free()
		var weapon: PackedScene = load("res://scenes/weapons/" + ["sword", "longsword", "axe", "club", "staff"][Global.selectedweapontype] + ".tscn")
		var new_weapon: Weapon = weapon.instantiate()
		space.connect(new_weapon.on_space)
		new_weapon.state_change.connect(func(new_weapon_state: Weapon._STATES) -> void: weapon_state = new_weapon_state)
		add_child(new_weapon)
	
	if Input.is_action_just_pressed("inventory"):
		inventoryisopen = !inventoryisopen
		if inventoryisopen:
			print(inventory)
			%UI.reset_inventory_desc()
		inventory_ref.visible = inventoryisopen

var cycle := 0
var old_pos := Vector2.ZERO
var p_dis := Vector2.ZERO
var practical_velocity := Vector2.ZERO
func update_practical_velocity() -> void:
	p_dis += global_position - old_pos
	practical_velocity = p_dis / $PracticalVelocityTimer.wait_time / (cycle + 1)
	old_pos = global_position
	
	if cycle == 2:
		cycle = 0
		p_dis = Vector2.ZERO
	cycle += 1

func stun(length: float) -> void:
	stunned = true
	change_state(_STATES.PAUSE)
	forces[0] = Vector2.ZERO
	$StunTimer.wait_time = length
	$StunTimer.start()

func stun_timer_timeout() -> void:
	stunned = false

func beartrap(trap_pos: Vector2) -> void:
	stun(3.5)
	change_health(-20.0)
	global_position = trap_pos - Vector2(0, 6)

func isAttacking() -> bool:
	return weapon_state == Weapon._STATES.ATTACK1
