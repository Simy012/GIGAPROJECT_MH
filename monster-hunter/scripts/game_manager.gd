extends Node




func _ready():
	pass

func become_host():
	print("Become host pressed")
	_remove_single_player()
	%SteamHUD.hide()
	%NetworkManager.become_host()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func join_as_client():
	print("Join as player 2")
	join_lobby()

func use_steam():
	print("Using Steam!")	
	%SteamHUD.show()
	SteamManager.initialize_steam()
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	%NetworkManager.active_network_type = %NetworkManager.MULTIPLAYER_NETWORK_TYPE.STEAM

func list_steam_lobbies():
	print("List Steam lobbies")
	%NetworkManager.list_lobbies()

func join_lobby(lobby_id = 0):
	print("Joining lobby %s" % lobby_id)
	_remove_single_player()
	%SteamHUD.hide()
	%NetworkManager.join_as_client(lobby_id)

func _on_lobby_match_list(lobbies: Array):
	print("On lobby match list")
	
	for lobby_child in $"../CanvasLayer/SteamHUD/Lobbies/VBoxContainer".get_children():
		
		lobby_child.queue_free()
		
	for lobby in lobbies:
		var lobby_name: String = Steam.getLobbyData(lobby, "name")
		
		if lobby_name != "":
			var lobby_mode: String = Steam.getLobbyData(lobby, "mode")
			
			var lobby_button: Button = Button.new()
			lobby_button.set_text(lobby_name + " | " + lobby_mode)
			lobby_button.set_size(Vector2(100, 30))
			lobby_button.add_theme_font_size_override("font_size", 8)
			
			
			lobby_button.set_name("lobby_%s" % lobby)
			lobby_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			lobby_button.connect("pressed", Callable(self, "join_lobby").bind(lobby))
			
			$"../CanvasLayer/SteamHUD/Lobbies/VBoxContainer".add_child(lobby_button)
			

func _remove_single_player():
	print("Remove single player")
	var player_to_remove = get_tree().get_current_scene().get_node("Players").get_child(0)
	if player_to_remove:
		player_to_remove.queue_free()
