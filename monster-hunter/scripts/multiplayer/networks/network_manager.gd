extends Node

enum MULTIPLAYER_NETWORK_TYPE { ENET, STEAM }

var players_spawn_node: Node3D
var active_network_type: MULTIPLAYER_NETWORK_TYPE = MULTIPLAYER_NETWORK_TYPE.STEAM
var active_network

var enet_network_scene := preload("res://scenes/multiplayer/networks/enet_network.tscn")
var steam_network_scene := preload("res://scenes/multiplayer/networks/steam_network.tscn")

signal network_ready

func _ready():
	print("NetworkManager initialized")

func set_players_spawn_node(node: Node3D):
	"""
	Wird von der Main Scene aufgerufen um die Spawn-Position zu setzen
	"""
	players_spawn_node = node
	print("Players spawn node set: %s" % node.name)

func build_multiplayer_network():
	if active_network:
		print("Network already built")
		return
	
	print("Building multiplayer network...")
	MultiplayerManager.multiplayer_mode_enabled = true
	
	match active_network_type:
		MULTIPLAYER_NETWORK_TYPE.ENET:
			print("Setting network type to ENet")
			set_active_network(enet_network_scene)
		MULTIPLAYER_NETWORK_TYPE.STEAM:
			print("Setting network type to Steam")
			set_active_network(steam_network_scene)
		_:
			print("No match for network type!")

func set_active_network(active_network_scene: PackedScene):
	var network_scene_initialized = active_network_scene.instantiate()
	active_network = network_scene_initialized
	
	# Spawn node setzen wenn vorhanden
	if players_spawn_node:
		active_network._players_spawn_node = players_spawn_node
	
	add_child(active_network)
	network_ready.emit()
	print("Network built and ready!")

func become_host(is_dedicated_server: bool = false):
	build_multiplayer_network()
	MultiplayerManager.host_mode_enabled = true if is_dedicated_server == false else false
	
	# Warte bis Network bereit ist
	if not active_network:
		await network_ready
	
	active_network.become_host()
	print("Became host!")

func join_as_client(lobby_id: int = 0):
	build_multiplayer_network()
	
	# Warte bis Network bereit ist
	if not active_network:
		await network_ready
	
	active_network.join_as_client(lobby_id)
	print("Joining as client!")

func list_lobbies():
	build_multiplayer_network()
	
	# Warte bis Network bereit ist
	if not active_network:
		await network_ready
	
	print("Listing lobbies...")
	active_network.list_lobbies()

func cleanup_network():
	if active_network:
		print("Cleaning up network...")
		active_network.queue_free()
		active_network = null
		MultiplayerManager.multiplayer_mode_enabled = false
		MultiplayerManager.host_mode_enabled = false

func set_network_type(type: MULTIPLAYER_NETWORK_TYPE):
	"""
	Netzwerk-Typ ändern (z.B. von Menu aus)
	"""
	if active_network:
		push_warning("Cannot change network type while network is active!")
		return
	
	active_network_type = type
	print("Network type set to: %s" % ["ENET", "STEAM"][type])
