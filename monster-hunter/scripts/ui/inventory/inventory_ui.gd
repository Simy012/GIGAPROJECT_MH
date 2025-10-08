class_name InventoryGUI
extends Control

signal inventory_opened
signal inventory_closed

@export var inventory: Inventory
@export var grid_container: GridContainer
@export var filter_buttons: OptionButton
var item_slot_scene: PackedScene = preload(GlobalData.ITEM_SLOT_SCENE)

enum FilterType {
	ALL,
	RESOURCES,
	WEAPONS,
	ARMOR,
	CONSUMABLES
}

var current_filter: FilterType = FilterType.ALL
var item_slots: Array[Control] = []

func _ready() -> void:
	inventory_opened.connect(on_inventory_opened)
	inventory_closed.connect(on_inventory_closed)
	if inventory:
		inventory.inventory_changed.connect(_on_inventory_changed)
		setup_filter_buttons()
		refresh_ui()

func setup_filter_buttons() -> void:
	if not filter_buttons:
		return
	
	var filters = ["All", "Resources", "Weapons", "Armor", "Consumables"]
	for i in filters.size():
		var btn = Button.new()
		btn.text = filters[i]
		btn.pressed.connect(_on_filter_pressed.bind(i))
		filter_buttons.add_child(btn)

func _on_filter_pressed(filter: int) -> void:
	current_filter = filter as FilterType
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
	
	if current_filter == FilterType.ALL:
		return all_items
	
	var filtered: Array[ItemStack] = []
	for stack in all_items:
		var matches = false
		match current_filter:
			FilterType.RESOURCES:
				matches = stack.item.item_type == Item.ItemType.RESOURCE or \
						  stack.item.item_type == Item.ItemType.MATERIAL
			FilterType.WEAPONS:
				matches = stack.item.item_type == Item.ItemType.WEAPON
			FilterType.ARMOR:
				matches = stack.item.item_type == Item.ItemType.ARMOR
			FilterType.CONSUMABLES:
				matches = stack.item.item_type == Item.ItemType.CONSUMABLE
		
		if matches:
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
	refresh_ui()

func on_inventory_closed():
	visible = false


func _on_option_button_item_selected(index):
	match filter_buttons.get_item_text(index):
		"All":
			current_filter = FilterType.ALL
		"Resources":
			current_filter = FilterType.RESOURCES
		"Weapons":
			current_filter = FilterType.WEAPONS
		"Armors":
			current_filter = FilterType.ARMOR
		_:
			current_filter = FilterType.ALL
	print("Set Filter to: %s" % current_filter)
	refresh_ui()
