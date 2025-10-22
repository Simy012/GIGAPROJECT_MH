extends Node
## ============================================================================
## MONSTER HUNTER - SAVE DATA COLLECTOR
## ============================================================================
## 
## Dies ist der SPIELSPEZIFISCHE Teil des Save-Systems.
## Hier wird festgelegt, WELCHE Daten gespeichert werden.
## 
## Das UniversalSaveSystem ist generisch und weiß nichts über dein Spiel.
## Dieser Collector sammelt alle relevanten Spieldaten und übergibt sie
## an das UniversalSaveSystem.
##
## FÜR ANDERE SPIELE: Erstelle einfach einen anderen Collector!
## ============================================================================

class_name MonsterHunterSaveCollector

## Referenzen zu Spiel-Systemen (werden automatisch gefunden)
var player: Player
var inventory_system: Inventory
var quest_system: Node
var weapon_system: Node
var stats_system: Node

func _ready():
	EventHandler.local_player_registered.connect(_on_local_player_registered)


func _on_local_player_registered(loc_player: Player):
	player = loc_player


## ============================================================================
## DATEN SAMMELN (Game -> Save System)
## ============================================================================

## Sammelt ALLE relevanten Spieldaten in ein Dictionary
## @return: Dictionary mit allen Spieldaten
func collect_all_game_data() -> Dictionary:
	print("📊 Sammle Spieldaten...")
	
	var game_data = {
		# Metadaten (werden vom SaveSystem separat behandelt)
		"_metadata": _collect_metadata(),
		
		# Charakter Daten
		"character": _collect_character_data(),
		
		# Inventar
		"inventory": _collect_inventory_data(),
		
		# Quests
		"quests": _collect_quest_data(),
		
		# Monster Statistiken
		"monsters": _collect_monster_data(),
		
		# Welt-Status
		"world": _collect_world_data(),
		
		# Statistiken
		"statistics": _collect_statistics_data()
	}
	
	print("✅ Datensammlung abgeschlossen")
	return game_data


## Sammelt Metadaten für die Slot-Anzeige
func _collect_metadata() -> Dictionary:
	var playtime = 0.0
	
	return {
		"play_time": playtime,
		"save_date": Time.get_datetime_string_from_system()
	}


## Sammelt Charakter-Daten
func _collect_character_data() -> Dictionary:
	var data = {
		"name": "Unnamed",
		"level": 1,
		"experience": 0,
		"health": 100.0,
		"max_health": 100.0,
		"stamina" : 100.0,
		"max_stamina": 100.0,
		"appearance": {},
		"stats": {}
		}
	
	if player:
		data["name"] = player.character_name
		data["level"] = player.get_level()
		data["experience"] = player.get_current_experience()
		data["health"] = player.get_current_health()
		data["max_health"] = player.get_max_health()
	
	return data


## Sammelt Inventar-Daten
func _collect_inventory_data() -> Dictionary:
	var data = {
		"items": [],
		"equipment": {
			"weapon": null,
			"head_armor": null,
			"chest_armor": null,
			"arms_armor": null,
			"waist_armor": null,
			"legs_armor": null,
			"charm": null
		},
		"item_pouch": [],
		"currency": 0,
		"research_points": 0
	}
	
	# Versuche Inventar-System zu finden
	if has_node("/root/InventorySystem"):
		var inv = get_node("/root/InventorySystem")
		
		if inv.has("items"):
			data["items"] = _duplicate_array(inv.items)
		if inv.has("equipment"):
			data["equipment"] = inv.equipment.duplicate(true)
		if inv.has("currency"):
			data["currency"] = inv.currency
	
	return data


## Sammelt Quest-Daten
func _collect_quest_data() -> Dictionary:
	var data = {
		"completed_quests": [],
		"active_quests": [],
		"quest_progress": {},
		"story_flags": {}
	}
	
	# Versuche Quest-System zu finden
	if has_node("/root/QuestSystem"):
		var quest_sys = get_node("/root/QuestSystem")
		
		if quest_sys.has("completed_quests"):
			data["completed_quests"] = quest_sys.completed_quests.duplicate()
		if quest_sys.has("active_quests"):
			data["active_quests"] = _duplicate_array(quest_sys.active_quests)
		if quest_sys.has("story_flags"):
			data["story_flags"] = quest_sys.story_flags.duplicate(true)
	
	return data


## Sammelt Monster-Statistiken
func _collect_monster_data() -> Dictionary:
	var data = {
		"monsters_hunted": {},
		"monsters_captured": {},
		"monster_research": {},
		"total_hunted": 0,
		"total_captured": 0
	}
	
	# Versuche Monster-Tracker zu finden
	if has_node("/root/MonsterTracker"):
		var tracker = get_node("/root/MonsterTracker")
		
		if tracker.has("monsters_hunted"):
			data["monsters_hunted"] = tracker.monsters_hunted.duplicate(true)
		if tracker.has("monsters_captured"):
			data["monsters_captured"] = tracker.monsters_captured.duplicate(true)
		if tracker.has("total_hunted"):
			data["total_hunted"] = tracker.total_hunted
	
	return data


## Sammelt Welt-Status
func _collect_world_data() -> Dictionary:
	var data = {
		"current_map": "base_camp",
		"unlocked_maps": [],
		"discovered_locations": [],
		"time_of_day": 12.0,
		"weather": "clear"
	}
	
	# Versuche World-Manager zu finden
	if has_node("/root/WorldManager"):
		var world = get_node("/root/WorldManager")
		
		if world.has("current_map"):
			data["current_map"] = world.current_map
		if world.has("unlocked_maps"):
			data["unlocked_maps"] = world.unlocked_maps.duplicate()
	
	return data




## Sammelt Spielstatistiken
func _collect_statistics_data() -> Dictionary:
	return {
		"play_time": 0.0,
		"deaths": 0,
		"faints": 0,
		"items_crafted": 0,
		"distance_traveled": 0.0,
		"damage_dealt": 0,
		"damage_taken": 0
	}


## ============================================================================
## DATEN WIEDERHERSTELLEN (Save System -> Game)
## ============================================================================

## Wendet geladene Daten auf das Spiel an
## @param game_data: Dictionary mit geladenen Spieldaten
func apply_loaded_data(game_data: Dictionary) -> void:
	print("📥 Wende geladene Daten an...")
	
	_apply_character_data(game_data.get("character", {}))
	_apply_inventory_data(game_data.get("inventory", {}))
	_apply_quest_data(game_data.get("quests", {}))
	_apply_monster_data(game_data.get("monsters", {}))
	_apply_world_data(game_data.get("world", {}))
	
	print("✅ Daten erfolgreich angewendet")


func _apply_character_data(data: Dictionary) -> void:
	if has_node("/root/Player"):
		var p = get_node("/root/Player")
		
		if data.has("name") and p.has("character_name"):
			p.character_name = data["name"]
		if data.has("level") and p.has("level"):
			p.level = data["level"]
		if data.has("health") and p.has("health"):
			p.health = data["health"]
		if data.has("position") and p.has("global_position"):
			var pos = data["position"]
			p.global_position = Vector3(pos.get("x", 0), pos.get("y", 0), pos.get("z", 0))


func _apply_inventory_data(data: Dictionary) -> void:
	if has_node("/root/InventorySystem"):
		var inv = get_node("/root/InventorySystem")
		
		if data.has("items") and inv.has("items"):
			inv.items = _duplicate_array(data["items"])
		if data.has("currency") and inv.has("currency"):
			inv.currency = data["currency"]


func _apply_quest_data(data: Dictionary) -> void:
	if has_node("/root/QuestSystem"):
		var quest_sys = get_node("/root/QuestSystem")
		
		if data.has("completed_quests"):
			quest_sys.completed_quests = data["completed_quests"].duplicate()


func _apply_monster_data(data: Dictionary) -> void:
	if has_node("/root/MonsterTracker"):
		var tracker = get_node("/root/MonsterTracker")
		
		if data.has("monsters_hunted"):
			tracker.monsters_hunted = data["monsters_hunted"].duplicate(true)


func _apply_world_data(data: Dictionary) -> void:
	if has_node("/root/WorldManager"):
		var world = get_node("/root/WorldManager")
		
		if data.has("current_map"):
			world.current_map = data["current_map"]


## ============================================================================
## HILFSFUNKTIONEN
## ============================================================================

## Dupliziert ein Array sicher (auch mit nested dictionaries)
func _duplicate_array(arr: Array) -> Array:
	var result = []
	for item in arr:
		if typeof(item) == TYPE_DICTIONARY:
			result.append(item.duplicate(true))
		elif typeof(item) == TYPE_ARRAY:
			result.append(_duplicate_array(item))
		else:
			result.append(item)
	return result
