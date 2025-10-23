class_name Inventory
extends Node

signal item_added(item: Item, quantity: int)
signal item_removed(item: Item, quantity: int)
signal inventory_changed()

var items: Array[ItemStack] = []



func add_item(item: Item, quantity: int = 1) -> bool:
	if not item or quantity <= 0:
		return false
	
	var remaining = quantity
	
	# Versuche zu bestehenden Stacks hinzuzufügen
	if item.can_stack():
		for stack in items:
			if stack.item.item_id == item.item_id and not stack.is_full():
				remaining = stack.add(remaining)
				if remaining <= 0:
					break
	
	# Erstelle neue Stacks für verbleibende Items
	while remaining > 0:
		var new_stack = ItemStack.new(item, 0)
		var added = new_stack.add(remaining)
		remaining = added
		items.append(new_stack)
	
	item_added.emit(item, quantity)
	inventory_changed.emit()
	return true

func remove_item(item_to_remove: Item, quantity: int = 1) -> bool:
	if quantity <= 0:
		return false
	
	var remaining = quantity
	var removed_item: Item = null
	
	# Durchsuche alle Stacks und entferne Items
	for i in range(items.size() - 1, -1, -1):
		var stack = items[i]
		if stack.item.item_id == item_to_remove.item_id:
			removed_item = stack.item
			var removed = stack.remove(remaining)
			remaining -= removed
			
			# Entferne leere Stacks
			if stack.is_empty():
				items.remove_at(i)
			
			if remaining <= 0:
				break
	
	var actually_removed = quantity - remaining
	if actually_removed > 0 and removed_item:
		item_removed.emit(removed_item, actually_removed)
		inventory_changed.emit()
		return remaining == 0
	
	return false

func has_item(item_id: String, quantity: int = 1) -> bool:
	var total = get_item_count(item_id)
	return total >= quantity

func get_item_count(item_id: String) -> int:
	var count = 0
	for stack in items:
		if stack.item.item_id == item_id:
			count += stack.quantity
	return count

func get_all_items() -> Array[ItemStack]:
	return items.duplicate()

func get_items_by_type(type: Item.ItemType) -> Array[ItemStack]:
	var result: Array[ItemStack] = []
	for stack in items:
		if stack.item.item_type == type:
			result.append(stack)
	return result

func clear() -> void:
	items.clear()
	inventory_changed.emit()

func get_total_item_count() -> int:
	var total = 0
	for stack in items:
		total += stack.quantity
	return total

func get_slot_count() -> int:
	return items.size()


func load_inventory(inv_data: Dictionary):
	if inv_data.is_empty():
		push_error("Error loading inventory: data empty")
		return
	
	if not inv_data.has("items"):
		push_error("Error loading inventory: missing 'items'")
		return
	
	# Inventar leeren, bevor du neu befüllst
	items.clear()
	
	for item_entry in inv_data["items"]:
		for item_id in item_entry.keys():
			var quantity = item_entry[item_id]
			if quantity <= 0:
				continue
			var item = ItemDatabase.get_item(item_id)
			if item:
				items.append(ItemStack.new(item, quantity))
			else:
				push_warning("Unknown item ID in save: " + str(item_id))
	
	print("Inventory loaded successfully!")
