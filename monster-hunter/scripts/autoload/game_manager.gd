extends Node

enum GameMode {
	SINGLEPLAYER,
	MULTIPLAYER_HOST,
	MULTIPLAYER_CLIENT
}

var current_game_mode: GameMode = GameMode.SINGLEPLAYER
var is_game_paused: bool = false
var steam_initialized: bool = false

var main_node:  MainNode


signal game_mode_changed(mode: GameMode)
signal steam_ready

func _ready():
	EventHandler.save_game.connect(save_game)
	# Steam automatisch initialisieren beim Start
	initialize_steam()


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




func load_scene(scene_path: String):
	SceneTransition.change_scene(scene_path)

"""
func pause_game():
	is_game_paused = true
	get_tree().paused = true

func resume_game():
	is_game_paused = false
	get_tree().paused = false
"""


func _add_player_to_game(id: int):
	if not multiplayer.is_server():
		return
	print("Adding Player with ID: %s" % id)
	
	var player_to_add = GlobalData.multiplayer_scene.instantiate()
	player_to_add.player_id = id
	player_to_add.name = str(id)
	
	if not main_node.get_player_spawn_point():
		print("ERROR: Spawnnode war null, als Spieler hinzugefügt werden sollte")
		return
	
	main_node.get_player_spawn_point().add_child(player_to_add, true)
	EventHandler.player_added.emit(player_to_add)
	print("Player %s spawned successfully!" % id)

func _del_player(id: int):
	if not multiplayer.is_server():
		return
	print("Player %s left the game!" % id)
	if not main_node.get_player_spawn_point().has_node(str(id)):
		return
	main_node.get_player_spawn_point().get_node(str(id)).call_deferred("queue_free")


func quit_game():
	get_tree().quit()

func save_game():
	var data = DataCollector.collect_all_game_data()
	SaveManager.save_game(SaveManager.current_slot, data)
