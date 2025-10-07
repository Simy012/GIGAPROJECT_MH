extends Node


var multiplayer_peer: SteamMultiplayerPeer = SteamMultiplayerPeer.new()
var _hosted_lobby_id = 0

var LOBBY_NAME: String 
const LOBBY_MODE = "CoOP"

func  _ready():
	# Steam Signals verbinden
	Steam.lobby_created.connect(_on_lobby_created.bind())
	Steam.lobby_kicked.connect(_on_lobby_kicked.bind())
	print("SteamNetwork Ready")
	print("Steam P2P Allowed: %s" % Steam.allowP2PPacketRelay(true))


func become_host():
	print("Starting host!")
	
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(_del_player)
	
	Steam.lobby_joined.connect(_on_lobby_joined.bind())
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, SteamManager.lobby_max_members)



func join_as_client(lobby_id):
	print("Joining lobby %s" % lobby_id)
	Steam.lobby_joined.connect(_on_lobby_joined.bind())
	Steam.joinLobby(int(lobby_id))


func _on_lobby_created(connect: int, lobby_id):
	print("On lobby created")
	if connect == 1:
		_hosted_lobby_id = lobby_id
		print("Created lobby: %s" % _hosted_lobby_id)
		
		Steam.setLobbyJoinable(_hosted_lobby_id, true)
		
		LOBBY_NAME = str(Steam.getPersonaName())
		Steam.setLobbyData(_hosted_lobby_id, "name", LOBBY_NAME)
		Steam.setLobbyData(_hosted_lobby_id, "mode", LOBBY_MODE)
		
		_create_host()
	else:
		print("STEAM: Error on create Lobby")


func _create_host():
	print("Create Host")
	var error = multiplayer_peer.create_host(0)
	if error == OK:
		multiplayer.set_multiplayer_peer(multiplayer_peer)
		
		if not OS.has_feature("dedicated_server"):
			_add_player_to_game(1)
	else:
		print("Error creating host: %s", str(error))



func _on_lobby_joined(lobby_id: int, permissions: int, locked: bool, response: int):
	print("On lobby joined")
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:  # Success
		print("STEAM: Successfully joined Steam lobby!")
		var id = Steam.getLobbyOwner(lobby_id)
		if id != Steam.getSteamID():
			print("Connecting to socket...")
			connect_socket(id)
	else:
		# Get the failure reason
		var FAIL_REASON: String
		match response:
			Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST: FAIL_REASON = "This lobby no longer exists."
			Steam.CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED: FAIL_REASON = "You don't have permission to join this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_FULL: FAIL_REASON = "The lobby is now full."
			Steam.CHAT_ROOM_ENTER_RESPONSE_ERROR: FAIL_REASON = "Uh... something unexpected happened!"
			Steam.CHAT_ROOM_ENTER_RESPONSE_BANNED: FAIL_REASON = "You are banned from this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_LIMITED: FAIL_REASON = "You cannot join due to having a limited account."
			Steam.CHAT_ROOM_ENTER_RESPONSE_CLAN_DISABLED: FAIL_REASON = "This lobby is locked or disabled."
			Steam.CHAT_ROOM_ENTER_RESPONSE_COMMUNITY_BAN: FAIL_REASON = "This lobby is community locked."
			Steam.CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU: FAIL_REASON = "A user in the lobby has blocked you from joining."
			Steam.CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER: FAIL_REASON = "A user you have blocked is in the lobby."
		print("SteamLobby Join Error Message:" + FAIL_REASON)


func connect_socket(steam_id: int):
	var error = multiplayer_peer.create_client(steam_id,0)
	if error == OK:
		print("Connecting peer to host...")
		multiplayer.set_multiplayer_peer(multiplayer_peer)
	else: 
		print("Error creating client: %s", str(error))


func list_lobbies():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	# NOTE: If you are using the test app id, you will need to apply a filter on your game name
	# Otherwise, it may not show up in the lobby list of your clients
	#Steam.addRequestLobbyListStringFilter("name", LOBBY_NAME, Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()


func _on_lobby_kicked(lobby_id: int, lobby_owner_id: int, reason: int):
	print("You got kicked from Lobby for reason: ", reason)



func _add_player_to_game(id: int):
	if not multiplayer.is_server():
		return
	print("Adding Player with ID: %s" % id)
	
	var player_to_add = GlobalData.multiplayer_scene.instantiate()
	player_to_add.player_id = id
	player_to_add.name = str(id)
	
	player_to_add.set_multiplayer_authority(id)
	
	NetworkManager.players_spawn_node.add_child(player_to_add, true)
	EventHandler.player_added.emit(player_to_add)
	print("Player %s spawned successfully!" % id)


func _del_player(id: int):
	if not multiplayer.is_server():
		return
	print("Player %s left the game!" % id)
	if not NetworkManager.players_spawn_node.has_node(str(id)):
		return
	NetworkManager.players_spawn_node.get_node(str(id)).queue_free()
