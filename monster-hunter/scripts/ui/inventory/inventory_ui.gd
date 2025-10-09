class_name InventoryGUI
extends Control

signal inventory_opened
signal inventory_closed

@export var inventory: Inventory
@export var grid_container: GridContainer
@export var filter_type_button: OptionButton
@export var filter_rarity_button: OptionButton
var item_slot_scene: PackedScene = preload(GlobalData.ITEM_SLOT_SCENE)

enum FilterType {
	ALL,
	RESOURCES,
	WEAPONS,
	ARMOR,
	CONSUMABLES
}

enum FilterRarity {
	ALL,
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}



var current_type_filter: FilterType = FilterType.ALL
var current_rarity_filter: FilterRarity = FilterRarity.ALL

var item_slots: Array[Control] = []

func _ready() -> void:
	inventory_opened.connect(on_inventory_opened)
	inventory_closed.connect(on_inventory_closed)
	if inventory:
		inventory.inventory_changed.connect(_on_inventory_changed)
		refresh_ui()



func refresh_ui() -> void:
	clear_slots()
	
	if not inventory or not grid_container:
		return
	
	var items_to_display = get_filtered_items()
	
	for item_stack in items_to_display:
		create_item_slot(item_stack)

func get_filtered_items() -> Array[ItemStack]:
	var all_items = inventory.get_all_items()
	
	if current_type_filter == FilterType.ALL and current_rarity_filter == FilterRarity.ALL:
		return all_items
	
	var filtered: Array[ItemStack] = []

	for stack in all_items:
		var item = stack.item
		
		# === Typ-Filter ===
		var type_matches := false
		match current_type_filter:
			FilterType.ALL:
				type_matches = true
			FilterType.RESOURCES:
				type_matches = item.item_type == Item.ItemType.RESOURCE
			FilterType.WEAPONS:
				type_matches = item.item_type == Item.ItemType.WEAPON
			FilterType.ARMOR:
				type_matches = item.item_type == Item.ItemType.ARMOR
			FilterType.CONSUMABLES:
				type_matches = item.item_type == Item.ItemType.CONSUMABLE
		
		if not type_matches:
			continue
		
		# === Rarity-Filter ===
		var rarity_matches := false
		match current_rarity_filter:
			FilterRarity.ALL:
				rarity_matches = true
			FilterRarity.COMMON:
				rarity_matches = item.rarity == Item.Rarity.COMMON
			FilterRarity.UNCOMMON:
				rarity_matches = item.rarity == Item.Rarity.UNCOMMON
			FilterRarity.RARE:
				rarity_matches = item.rarity == Item.Rarity.RARE
			FilterRarity.EPIC:
				rarity_matches = item.rarity == Item.Rarity.EPIC
			FilterRarity.LEGENDARY:
				rarity_matches = item.rarity == Item.Rarity.LEGENDARY
		
		if not rarity_matches:
			continue
		
		filtered.append(stack)
	
	return filtered

func create_item_slot(item_stack: ItemStack) -> void:
	if not item_slot_scene:
		push_error("Item Slot Scene nicht zugewiesen!")
		return
	
	var slot = item_slot_scene.instantiate()
	grid_container.add_child(slot)
	item_slots.append(slot)
	
	# Setze Item Daten (benötigt entsprechende Methoden in der ItemSlot Szene)
	if slot.has_method("set_item_stack"):
		slot.set_item_stack(item_stack)

func clear_slots() -> void:
	for slot in item_slots:
		slot.queue_free()
	item_slots.clear()

func _on_inventory_changed() -> void:
	refresh_ui()

func on_inventory_opened():
	visible = true
	current_type_filter = FilterType.ALL
	refresh_ui()

func on_inventory_closed():
	visible = false


func _on_filter_type_selected(index):
	match filter_type_button.get_item_text(index):
		"All":
			current_type_filter = FilterType.ALL
		"Resources":
			current_type_filter = FilterType.RESOURCES
		"Weapons":
			current_type_filter = FilterType.WEAPONS
		"Armors":
			current_type_filter = FilterType.ARMOR
		_:
			current_type_filter = FilterType.ALL
	print("Set Type Filter to: %s" % current_type_filter)
	refresh_ui()


func _on_filter_rarity_selected(index):
	match filter_rarity_button.get_item_text(index):
		"All":
			current_rarity_filter = FilterRarity.ALL
		"Common":
			current_rarity_filter = FilterRarity.COMMON
		"Uncommon":
			current_rarity_filter = FilterRarity.UNCOMMON
		"Rare":
			current_rarity_filter = FilterRarity.RARE
		"Epic":
			current_rarity_filter = FilterRarity.EPIC
		"Legendary":
			current_rarity_filter = FilterRarity.LEGENDARY
		_:
			current_rarity_filter = FilterRarity.ALL
	print("Set Rarity Filter to: %s" % current_rarity_filter)
	refresh_ui()
