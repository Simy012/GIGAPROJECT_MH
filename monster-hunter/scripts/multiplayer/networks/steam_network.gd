extends Node

var multiplayer_scene = preload("res://scenes/entities/player/player.tscn")
var multiplayer_peer: SteamMultiplayerPeer = SteamMultiplayerPeer.new()
var _hosted_lobby_id = 0

const LOBBY_NAME = "MonsterHunterWILD"
const LOBBY_MODE = "CoOP"

func  _ready():
	# Steam Signals verbinden
	print("SteamNetwork Ready")
	print("Steam P2P Allowed: %s" % Steam.allowP2PPacketRelay(true))
	
	

func become_host():
	print("Starting host!")
	
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, SteamManager.lobby_max_members)


func _on_peer_connected(id: int):
	print("Peer %s connected to game!" % id)


func join_as_client(lobby_id):
	print("Joining lobby %s" % lobby_id)
	
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.joinLobby(lobby_id)
	
	# Warte auf erfolgreichen Join
	var result = await Steam.lobby_joined
	
	if result[3] != 1:  # result[3] = response code
		print("Failed to join lobby!")
		return
	
	# 2. Steam ID des Hosts holen
	var host_steam_id = Steam.getLobbyOwner(lobby_id)
	print("Host Steam ID: %s" % host_steam_id)
	
		# Multiplayer Peer zuweisen
	multiplayer.multiplayer_peer = multiplayer_peer
	
	# Client braucht auch diese Signals
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	
	# 3. Als Client zum Host connecten
	var error = multiplayer_peer.connect_to_lobby(lobby_id)
	if error != OK:
		print("Failed to create client! Error: %s" % error)
		return
	
	print("Client Setup complete")

func _on_peer_lobby_created(connect: int, lobby_id: int):
	print("Peer: Lobby created - ID: %s" % lobby_id)


func _on_lobby_created(connect: int, lobby_id):
	print("On lobby created")
	if connect == 1:
		_hosted_lobby_id = lobby_id
		print("Created lobby: %s" % _hosted_lobby_id)
		
		Steam.setLobbyJoinable(_hosted_lobby_id, true)
		
		Steam.setLobbyData(_hosted_lobby_id, "name", str(Steam.getPersonaName()) + LOBBY_NAME)
		Steam.setLobbyData(_hosted_lobby_id, "mode", LOBBY_MODE)
		
		# Wichtig: MultiplayerAPI den Peer zuweisen BEVOR host_with_lobby aufgerufen wird,
		# damit Godots `peer_connected` / `peer_disconnected` Signale aktiv sind.
		if multiplayer_peer:
			print("Close Existing Peer")
			multiplayer_peer.close()
	
		multiplayer_peer = SteamMultiplayerPeer.new()
		
		# WICHTIG: Debug-Level setzen
		multiplayer_peer.set_debug_level(2)  # 0=None, 1=Info, 2=Verbose
		
		# optional: debug / performance tweaks
		multiplayer_peer.set_no_delay(true)
		multiplayer_peer.set_debug_level(multiplayer_peer.DEBUG_LEVEL_STEAM)
		
		var err = multiplayer_peer.host_with_lobby(_hosted_lobby_id)
		if err != OK:
			print("host_with_lobby failed: %s" % err)
			return
		
		# Jetzt können wir die Multiplayer Signale binden und Hostspieler hinzufügen
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_del_player)
		
		# Host selbst spawnen (nur wenn kein dedicated server)
		if not OS.has_feature("dedicated_server"):
			_add_player_to_game(1)
		
		print("Host created successfully with lobby!")
	else:
		print("Error on create Lobby")


func _on_lobby_joined(lobby_id: int, permissions: int, locked: bool, response: int):
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:  # Success
		print("Successfully joined Steam lobby!")
	else:
		# Get the failure reason
		var FAIL_REASON: String
		match response:
			Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST:
				FAIL_REASON = "This lobby no longer exists."
			Steam.CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED:
				FAIL_REASON = "You don't have permission to join this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_FULL:
				FAIL_REASON = "The lobby is now full."
			Steam.CHAT_ROOM_ENTER_RESPONSE_ERROR:
				FAIL_REASON = "Uh... something unexpected happened!"
			Steam.CHAT_ROOM_ENTER_RESPONSE_BANNED:
				FAIL_REASON = "You are banned from this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_LIMITED:
				FAIL_REASON = "You cannot join due to having a limited account."
			Steam.CHAT_ROOM_ENTER_RESPONSE_CLAN_DISABLED:
				FAIL_REASON = "This lobby is locked or disabled."
			Steam.CHAT_ROOM_ENTER_RESPONSE_COMMUNITY_BAN:
				FAIL_REASON = "This lobby is community locked."
			Steam.CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU:
				FAIL_REASON = "A user in the lobby has blocked you from joining."
			Steam.CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER:
				FAIL_REASON = "A user you have blocked is in the lobby."
		print("SteamLobby Join Error Message:" + FAIL_REASON)


func _on_connected_to_server():
	print("Client: Connected to server!")
	
	# Client informiert Host über seine ID
	var my_id = multiplayer.get_unique_id()
	print("My unique ID: %s" % my_id)
	
	# Client spawnt sich NICHT selbst - der Host macht das!
	# Aber wir können ein RPC an den Host senden
	request_spawn.rpc_id(1, my_id)


func _on_connection_failed():
	print("Client: Connection failed!")


func list_lobbies():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	# NOTE: If you are using the test app id, you will need to apply a filter on your game name
	# Otherwise, it may not show up in the lobby list of your clients
	#Steam.addRequestLobbyListStringFilter("name", "BAD", Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()


func _add_player_to_game(id: int):
	if not multiplayer.is_server():
		return
	print("Adding Player with ID: %s" % id)
	
	var player_to_add = multiplayer_scene.instantiate()
	player_to_add.player_id = id
	player_to_add.name = str(id)
	
	player_to_add.set_multiplayer_authority(id)
	
	NetworkManager.players_spawn_node.add_child(player_to_add, true)
	
	print("Player %s spawned successfully!" % id)
	
	EventHandler.player_added.emit(player_to_add)
	
func _del_player(id: int):
	print("Player %s left the game!" % id)
	if not NetworkManager.players_spawn_node.has_node(str(id)):
		return
	NetworkManager.players_spawn_node.get_node(str(id)).queue_free()


@rpc("any_peer", "reliable")
func request_spawn(id: int):
	"""
	RPC vom Client an den Host um zu spawnen
	"""
	print("Received spawn request from ID: %s" % id)
	
	# Nur der Host darf spawnen
	if multiplayer.is_server():
		_add_player_to_game(id)











	
