class_name EquipmentManager
extends Node

signal equipment_changed(slot: String)
signal weapon_equipped(weapon: WeaponItem)
signal armor_equipped(armor: ArmorItem, slot: ArmorItem.ArmorSlot)

@export var player_node: Node3D # Der Spieler Node für 3D Modelle

var equipped_weapon: WeaponItem = null
var equipped_armor: Dictionary = {
	ArmorItem.ArmorSlot.HEAD: null,
	ArmorItem.ArmorSlot.CHEST: null,
	ArmorItem.ArmorSlot.ARMS: null,
	ArmorItem.ArmorSlot.WAIST: null,
	ArmorItem.ArmorSlot.LEGS: null
}

# 3D Modell References
var weapon_model: Node3D = null
var armor_models: Dictionary = {}

func equip_weapon(weapon: WeaponItem) -> bool:
	if not weapon:
		return false
	
	# Entferne alte Waffe
	if equipped_weapon:
		unequip_weapon()
	
	equipped_weapon = weapon
	load_weapon_model(weapon)
	weapon_equipped.emit(weapon)
	equipment_changed.emit("weapon")
	return true

func unequip_weapon() -> WeaponItem:
	var old_weapon = equipped_weapon
	equipped_weapon = null
	
	if weapon_model:
		weapon_model.queue_free()
		weapon_model = null
	
	equipment_changed.emit("weapon")
	return old_weapon

func equip_armor(armor: ArmorItem) -> bool:
	if not armor:
		return false
	
	var slot = armor.armor_slot
	
	# Entferne alte Rüstung in diesem Slot
	if equipped_armor[slot]:
		unequip_armor(slot)
	
	equipped_armor[slot] = armor
	load_armor_model(armor)
	armor_equipped.emit(armor, slot)
	equipment_changed.emit("armor_" + str(slot))
	return true

func unequip_armor(slot: ArmorItem.ArmorSlot) -> ArmorItem:
	var old_armor = equipped_armor[slot]
	equipped_armor[slot] = null
	
	if armor_models.has(slot) and armor_models[slot]:
		armor_models[slot].queue_free()
		armor_models.erase(slot)
	
	equipment_changed.emit("armor_" + str(slot))
	return old_armor

func load_weapon_model(weapon: WeaponItem) -> void:
	if not weapon.has_3d_model() or not player_node:
		return
	
	var model = load(weapon.model_path)
	if model and model is PackedScene:
		weapon_model = model.instantiate()
		# Füge zum Spieler hinzu (z.B. an Hand-Bone)
		player_node.add_child(weapon_model)
		# Hier könntest du das Modell an einen Bone attachen

func load_armor_model(armor: ArmorItem) -> void:
	if not armor.has_3d_model() or not player_node:
		return
	
	var model = load(armor.model_path)
	if model and model is PackedScene:
		var armor_model = model.instantiate()
		armor_models[armor.armor_slot] = armor_model
		player_node.add_child(armor_model)

func get_total_defense() -> int:
	var total = 0
	for armor in equipped_armor.values():
		if armor:
			total += armor.defense
	return total

func get_total_resistance(element: String) -> int:
	var total = 0
	for armor in equipped_armor.values():
		if armor:
			total += armor.get_resistance(element)
	return total

func get_all_skills() -> Dictionary:
	var skills = {}
	for armor in equipped_armor.values():
		if armor:
			for skill_data in armor.skills:
				var skill_name = skill_data.get("skill_name", "")
				var level = skill_data.get("level", 0)
				if skills.has(skill_name):
					skills[skill_name] += level
				else:
					skills[skill_name] = level
	return skills
