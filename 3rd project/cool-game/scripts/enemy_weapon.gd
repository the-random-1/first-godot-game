extends Area2D
class_name EnemyWeapon

enum _WEAPON_STATES {
	IDLE,
	ATTACK,
	PARRY
}

var weapon_state := _WEAPON_STATES.IDLE
