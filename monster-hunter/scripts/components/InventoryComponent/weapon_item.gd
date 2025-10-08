class_name WeaponItem
extends Item

enum WeaponType {
	SWORD,
	HAMMER,
	BOW,
	LANCE,
	DUAL_BLADES,
	HUNTING_HORN
}

@export var weapon_type: WeaponType = WeaponType.SWORD
@export var attack_power: int = 100
@export var sharpness: int = 50
@export var affinity: int = 0 # Kritische Chance in %
@export var element_type: String = "" # z.B. "Fire", "Ice", "Thunder"
@export var element_damage: int = 0
@export var slots: int = 0 # Für Dekorationen/Gems

# Crafting Requirements
@export var required_materials: Array[Dictionary] = []

func _init() -> void:
	super._init()
	item_type = ItemType.WEAPON
	max_stack_size = 1

func get_total_attack() -> int:
	return attack_power + element_damage

func has_element() -> bool:
	return element_type != "" and element_damage > 0
