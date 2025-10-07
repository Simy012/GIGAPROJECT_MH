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
	load_scene(GlobalData.MAIN_GAME_SCENE)

func start_multiplayer_host():
	print("Starting Multiplayer Host...")
	current_game_mode = GameMode.MULTIPLAYER_HOST
	game_mode_changed.emit(current_game_mode)
	
	# ERST Scene laden
	load_scene(GlobalData.MAIN_GAME_SCENE)
	
	# Warten bis Scene geladen ist
	await get_tree().tree_changed
	await get_tree().process_frame
	
	# DANN Singleplayer Character entfernen
	await remove_singleplayer_character()
	
	# Input freigeben
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	NetworkManager.become_host()
	print("Steam Network: Host started!")


func start_multiplayer_client(lobby_id: int):
	print("Joining Multiplayer as Client (Lobby: %s)..." % lobby_id)
	current_game_mode = GameMode.MULTIPLAYER_CLIENT
	game_mode_changed.emit(current_game_mode)
	
	# ERST Scene laden
	load_scene(GlobalData.MAIN_GAME_SCENE)
	
	# Warten bis Scene geladen ist
	await get_tree().tree_changed
	await get_tree().process_frame
	
	# DANN Singleplayer Character entfernen
	await remove_singleplayer_character()
	
	# Input freigeben
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Steam Network joinen (jetzt existiert die Scene)
	NetworkManager.join_as_client(lobby_id)
	print("Steam Network: Joined lobby %s!" % lobby_id)


func return_to_main_menu():
	current_game_mode = GameMode.SINGLEPLAYER
	load_scene(GlobalData.MAIN_MENU_SCENE)

func load_scene(scene_path: String):
	SceneTransition.change_scene(scene_path)

func quit_game():
	get_tree().quit()

func pause_game():
	is_game_paused = true
	get_tree().paused = true

func resume_game():
	is_game_paused = false
	get_tree().paused = false


func remove_singleplayer_character():
	print("Removing single player character...")
	
	# Warte einen Frame damit Scene vollständig geladen ist
	await get_tree().process_frame
	
	var player_node = NetworkManager.players_spawn_node
	
	if not player_node:
		print("No players Found")
		return
	
	# Entferne ersten Player (Singleplayer Character)
	if player_node.get_child_count() > 0:
		var player_to_remove = player_node.get_child(0)
		print("Removing player: %s" % player_to_remove.name)
		player_to_remove.queue_free()
		await player_to_remove.tree_exited
		print("Single player character removed!")
	else:
		print("No player to remove")
