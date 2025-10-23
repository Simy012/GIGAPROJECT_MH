extends Resource
class_name ItemDatabase

static var items = {
	# Weapons
	"dual_blades": preload("uid://c504lt16q5alb"),
	
	# Armor
	
	# Loot
	"lederhaut": preload("uid://cj8e8euayanqw"),
	"zahn": preload("uid://dt2200bgny55h"),
	
}

static func get_item(item_id: String) -> Item:
	return items[item_id]
