extends Node

# Menu Scenes
const MAIN_MENU_SCENE = "res://scenes/ui/menus/main_menu.tscn"
const SETTINGS_MENU_SCENE = "res://scenes/ui/menus/settings_menu.tscn"
const CHARACTER_SELECTION_SCENE = "res://scenes/ui/menus/character_selection.tscn"
const GAME_MODE_SELECTION_SCENE = "res://scenes/ui/menus/game_mode_selection.tscn"
const CHARACTER_CREATION_SCENE = "res://scenes/ui/menus/character_creation.tscn"

# Main Game Scene
const MAIN_GAME_SCENE = "res://scenes/main.tscn"

# Ingame menu Scenes
const INVENTORY_SCENE = "res://scenes/ui/inventory/inventory_gui.tscn"
const ITEM_SLOT_SCENE = "res://scenes/ui/inventory/item_slot.tscn"

# Player Scene
var multiplayer_scene = preload("res://scenes/entities/player/player.tscn")

# Network Scenes
var enet_network_scene := preload("res://scenes/multiplayer/networks/enet_network.tscn")
var steam_network_scene := preload("res://scenes/multiplayer/networks/steam_network.tscn")


# Enum für alle Level-Namen
enum LEVEL {
	NEXUS,
	HUNTINGGROUND1
}

# Hier werden alle Level-Szenen zentral geladen
const LEVEL_SCENES := {
	LEVEL.NEXUS: preload("res://scenes/level_scenes/nexus/nexus_scene.tscn"),
	LEVEL.HUNTINGGROUND1: preload("res://scenes/level_scenes/hunting_grounds/hunting_ground_1.tscn")
}

# Optional: Wenn du nur instanzieren willst
func get_level_instance(level: LEVEL) -> Scene:
	var scene = LEVEL_SCENES.get(level)
	if scene:
		return scene.instantiate()
	push_error("Level not found: %s" % str(level))
	return null
