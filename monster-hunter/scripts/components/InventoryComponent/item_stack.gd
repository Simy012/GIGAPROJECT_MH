class_name ItemStack
extends RefCounted

var item: Item
var quantity: int = 1

func _init(p_item: Item, p_quantity: int = 1) -> void:
	item = p_item
	quantity = clampi(p_quantity, 0, p_item.max_stack_size if p_item else 999)

func can_add(amount: int) -> bool:
	if not item:
		return false
	return quantity + amount <= item.max_stack_size

func add(amount: int) -> int:
	if not item:
		return amount
	
	var space_left = item.max_stack_size - quantity
	var amount_to_add = mini(amount, space_left)
	quantity += amount_to_add
	return amount - amount_to_add # Gibt übrige Menge zurück

func remove(amount: int) -> int:
	var amount_to_remove = mini(amount, quantity)
	quantity -= amount_to_remove
	return amount_to_remove

func is_empty() -> bool:
	return quantity <= 0 or item == null

func is_full() -> bool:
	if not item:
		return true
	return quantity >= item.max_stack_size

func can_stack_with(other: ItemStack) -> bool:
	if not item or not other or not other.item:
		return false
	return item.item_id == other.item.item_id and item.can_stack()

func duplicate_stack() -> ItemStack:
	return ItemStack.new(item, quantity)
