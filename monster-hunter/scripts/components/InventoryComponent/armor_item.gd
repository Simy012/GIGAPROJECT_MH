class_name ArmorItem
extends Item

enum ArmorSlot {
	HEAD,
	CHEST,
	ARMS,
	WAIST,
	LEGS
}

@export var armor_slot: ArmorSlot = ArmorSlot.CHEST
@export var defense: int = 50
@export var fire_resistance: int = 0
@export var water_resistance: int = 0
@export var thunder_resistance: int = 0
@export var ice_resistance: int = 0
@export var dragon_resistance: int = 0

# Skills die diese Rüstung gibt
@export var skills: Array[Dictionary] = [] # [{"skill_name": "Attack Boost", "level": 2}]
@export var slots: int = 0 # Für Dekorationen

# Crafting Requirements
@export var required_materials: Array[Dictionary] = []

func _init() -> void:
	super._init()
	item_type = ItemType.ARMOR
	max_stack_size = 1

func get_total_defense() -> int:
	return defense

func get_resistance(element: String) -> int:
	match element.to_lower():
		"fire":
			return fire_resistance
		"water":
			return water_resistance
		"thunder":
			return thunder_resistance
		"ice":
			return ice_resistance
		"dragon":
			return dragon_resistance
	return 0
