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
