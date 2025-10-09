class_name Item
extends Resource

enum ItemType {
	RESOURCE,
	WEAPON,
	ARMOR,
	CONSUMABLE,
	QUEST_ITEM
}

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}

@export var item_id: String = ""
@export var item_name: String = ""
@export_multiline var description: String = ""
@export var item_type: ItemType = ItemType.RESOURCE
@export var rarity: Rarity = Rarity.COMMON
@export var icon: Texture2D
@export var model_path: String = "" # Pfad zum 3D-Modell
@export var max_stack_size: int = 999
@export var is_tradeable: bool = true
@export var sell_price: int = 0

func _init() -> void:
	pass

func get_rarity_color() -> Color:
	match rarity:
		Rarity.COMMON:
			return Color.WHITE
		Rarity.UNCOMMON:
			return Color.GREEN
		Rarity.RARE:
			return Color.BLUE
		Rarity.EPIC:
			return Color.PURPLE
		Rarity.LEGENDARY:
			return Color.ORANGE
	return Color.WHITE

func can_stack() -> bool:
	return max_stack_size > 1

func has_3d_model() -> bool:
	return model_path != ""

func duplicate_item() -> Item:
	return self.duplicate(true)
