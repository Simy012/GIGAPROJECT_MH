extends Node

enum GameMode {
	SINGLEPLAYER,
	MULTIPLAYER_HOST,
	MULTIPLAYER_CLIENT
}

var current_game_mode: GameMode = GameMode.SINGLEPLAYER
var is_game_paused: bool = false
var steam_initialized: bool = false

# Scene Pfade
const MAIN_MENU_SCENE = "res://scenes/menus/main_menu.tscn"
const GAME_MODE_SELECTION_SCENE = "res://scenes/menus/game_mode_selection.tscn"
const MAIN_GAME_SCENE = "res://scenes/main.tscn"

signal game_mode_changed(mode: GameMode)
signal steam_ready

func _ready():
	# Steam automatisch initialisieren beim Start
	initialize_steam()


func initialize_steam():
	if steam_initialized:
		return
	
	print("Initializing Steam...")
	SteamManager.initialize_steam()
	steam_initialized = true
	steam_ready.emit()
	print("Steam initialized!")

func start_singleplayer():
	current_game_mode = GameMode.SINGLEPLAYER
	game_mode_changed.emit(current_game_mode)
	load_scene(MAIN_GAME_SCENE)

func start_multiplayer_host():
	print("Starting Multiplayer Host...")
	current_game_mode = GameMode.MULTIPLAYER_HOST
	game_mode_changed.emit(current_game_mode)
	
	# ERST Scene laden
	load_scene(MAIN_GAME_SCENE)
	
	# Warten bis Scene geladen ist
	await get_tree().tree_changed
	await get_tree().process_frame
	
	# DANN Singleplayer Character entfernen
	await remove_singleplayer_character()
	
	# Input freigeben
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Steam Network starten (jetzt existiert die Scene)
	if has_node("/root/SteamNetwork"):
		get_node("/root/SteamNetwork").become_host()
		print("Steam Network: Host started!")


func start_multiplayer_client(lobby_id: int):
	print("Joining Multiplayer as Client (Lobby: %s)..." % lobby_id)
	current_game_mode = GameMode.MULTIPLAYER_CLIENT
	game_mode_changed.emit(current_game_mode)
	
	# ERST Scene laden
	load_scene(MAIN_GAME_SCENE)
	
	# Warten bis Scene geladen ist
	await get_tree().tree_changed
	await get_tree().process_frame
	
	# DANN Singleplayer Character entfernen
	await remove_singleplayer_character()
	
	# Input freigeben
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Steam Network joinen (jetzt existiert die Scene)
	if has_node("/root/SteamNetwork"):
		get_node("/root/SteamNetwork").join_as_client(lobby_id)
		print("Steam Network: Joined lobby %s!" % lobby_id)
	
	

func return_to_main_menu():
	current_game_mode = GameMode.SINGLEPLAYER
	load_scene(MAIN_MENU_SCENE)

func load_scene(scene_path: String):
	get_tree().change_scene_to_file(scene_path)

func quit_game():
	get_tree().quit()

func pause_game():
	is_game_paused = true
	get_tree().paused = true

func resume_game():
	is_game_paused = false
	get_tree().paused = false


func remove_singleplayer_character():
	"""
	Entfernt den Singleplayer Character wenn in Multiplayer gewechselt wird
	"""
	print("Removing single player character...")
	
	# Warte einen Frame damit Scene vollständig geladen ist
	await get_tree().process_frame
	
	var current_scene = get_tree().current_scene
	if not current_scene:
		return
	
	# Suche nach Players Node
	if not current_scene.has_node("Players"):
		print("No Players node found")
		return
	
	var players_node = current_scene.get_node("Players")
	
	# Entferne ersten Player (Singleplayer Character)
	if players_node.get_child_count() > 0:
		var player_to_remove = players_node.get_child(0)
		print("Removing player: %s" % player_to_remove.name)
		player_to_remove.queue_free()
		await player_to_remove.tree_exited
		print("Single player character removed!")
	else:
		print("No player to remove")
