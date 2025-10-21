extends Node

enum GameMode {
	SINGLEPLAYER,
	MULTIPLAYER_HOST,
	MULTIPLAYER_CLIENT
}

var current_game_mode: GameMode = GameMode.SINGLEPLAYER
var is_game_paused: bool = false
var steam_initialized: bool = false

var players_spawn_node: Node3D


signal game_mode_changed(mode: GameMode)
signal steam_ready

func _ready():
	# Steam automatisch initialisieren beim Start
	initialize_steam()
	EventHandler.save_game.connect(save_game)


func initialize_steam():
	if steam_initialized:
		return
	
	print("Initializing Steam...")
	steam_initialized = SteamManager.initialize_steam()
	if steam_initialized:
		steam_ready.emit()
		print("Steam initialized!")
	else: 
		print("Failed to initialize Steam")


func start_singleplayer():
	current_game_mode = GameMode.SINGLEPLAYER
	game_mode_changed.emit(current_game_mode)
	load_scene(GlobalData.MAIN_GAME_SCENE)
	
	# Warten bis Scene geladen ist
	await get_tree().tree_changed
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Input freigeben
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	_add_player_to_game(1)
	print("Singleplayer started")

func start_multiplayer_host():
	print("Starting Multiplayer Host...")
	current_game_mode = GameMode.MULTIPLAYER_HOST
	game_mode_changed.emit(current_game_mode)
	
	# ERST Scene laden
	load_scene(GlobalData.MAIN_GAME_SCENE)
	
	# Warten bis Scene geladen ist
	await get_tree().tree_changed
	await get_tree().process_frame
	
	# Input freigeben
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	NetworkManager.become_host()
	print("Steam Network: Host started!")


func start_multiplayer_client(lobby_id: int = 0):
	print("Joining Multiplayer as Client (Lobby: %s)..." % lobby_id)
	current_game_mode = GameMode.MULTIPLAYER_CLIENT
	game_mode_changed.emit(current_game_mode)
	
	# ERST Scene laden
	load_scene(GlobalData.MAIN_GAME_SCENE)
	
	# Warten bis Scene geladen ist
	await get_tree().tree_changed
	await get_tree().process_frame
	
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


func _add_player_to_game(id: int):
	if not multiplayer.is_server():
		return
	print("Adding Player with ID: %s" % id)
	
	var player_to_add = GlobalData.multiplayer_scene.instantiate()
	player_to_add.player_id = id
	player_to_add.name = str(id)
	
	players_spawn_node.add_child(player_to_add, true)
	EventHandler.player_added.emit(player_to_add)
	print("Player %s spawned successfully!" % id)

func _del_player(id: int):
	if not multiplayer.is_server():
		return
	print("Player %s left the game!" % id)
	if not players_spawn_node.has_node(str(id)):
		return
	players_spawn_node.get_node(str(id)).queue_free()


func save_game():
	# Hier Datacollector daten bekommen und dann Savemanager save game aufrufen.
	pass
