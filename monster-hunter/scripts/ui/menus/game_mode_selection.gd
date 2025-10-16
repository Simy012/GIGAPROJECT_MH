extends Control

@onready var singleplayer_button = $Panel/MarginContainer/VBoxContainer/ButtonContainer/SingleplayerButton
@onready var multiplayer_button = $Panel/MarginContainer/VBoxContainer/ButtonContainer/MultiplayerButton
@onready var back_button = $Panel/MarginContainer/VBoxContainer/ButtonContainer/BackButton


@onready var multiplayer_panel = $MultiplayerPanel
@onready var lobby_list = $MultiplayerPanel/VBoxContainer/LobbyList
@onready var host_button = $MultiplayerPanel/VBoxContainer/HBoxContainer/HostButton
@onready var join_button = $MultiplayerPanel/VBoxContainer/HBoxContainer/JoinButton
@onready var refresh_button = $MultiplayerPanel/VBoxContainer/HBoxContainer/RefreshButton
@onready var close_mp_button = $MultiplayerPanel/VBoxContainer/CloseButton


func _ready():
	MultiplayerManager.multiplayer_mode_enabled_changed.connect(on_multiplayer_mode_enabled_changed)
	# Main buttons
	singleplayer_button.pressed.connect(_on_singleplayer_pressed)
	multiplayer_button.pressed.connect(_on_multiplayer_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	# Multiplayer buttons
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	refresh_button.pressed.connect(_on_refresh_pressed)
	close_mp_button.pressed.connect(_on_close_mp_pressed)
	
	if not MultiplayerManager.multiplayer_mode_enabled:
		print("No Connection to Steam")
		multiplayer_button.disabled = true
		
	# Hide multiplayer panel initially
	multiplayer_panel.visible = false
	
	# Connect Steam signals
	Steam.lobby_match_list.connect(_on_lobby_list_received)


func on_multiplayer_mode_enabled_changed(enabled: bool):
	if enabled:
		multiplayer_button.disabled = false
	else: 
		multiplayer_button.disabled = true

func _on_singleplayer_pressed():
	print("Starting Singleplayer...")
	GameManager.start_singleplayer()

func _on_multiplayer_pressed():
	multiplayer_panel.visible = true
	_on_refresh_pressed()

func _on_host_pressed():
	print("Hosting Steam Multiplayer Game...")
	NetworkManager.set_network_type(NetworkManager.MULTIPLAYER_NETWORK_TYPE.STEAM)
	GameManager.start_multiplayer_host()

func _on_join_pressed():
	if lobby_list.get_selected_items().size() > 0:
		var selected_idx = lobby_list.get_selected_items()[0]
		var lobby_id = lobby_list.get_item_metadata(selected_idx)
		print("Joining lobby: ", lobby_id)
		NetworkManager.set_network_type(NetworkManager.MULTIPLAYER_NETWORK_TYPE.STEAM)
		GameManager.start_multiplayer_client(lobby_id)
	else:
		print("Bitte wähle eine Lobby aus!")

func _on_refresh_pressed():
	lobby_list.clear()
	print("Suche nach Lobbies...")
	NetworkManager.list_lobbies()

func _on_close_mp_pressed():
	multiplayer_panel.visible = false

func _on_back_pressed():
	SceneTransition.change_scene(GlobalData.MAIN_MENU_SCENE)

func _on_lobby_list_received(lobbies: Array):
	lobby_list.clear()
	print("Found %d lobbies" % lobbies.size())
	
	for lobby_id in lobbies:
		var lobby_name = Steam.getLobbyData(lobby_id, "name")
		var lobby_mode = Steam.getLobbyData(lobby_id, "mode")
		var num_members = Steam.getNumLobbyMembers(lobby_id)
		var max_members = Steam.getLobbyMemberLimit(lobby_id)
		
		var lobby_text = "%s - %s [%d/%d]" % [lobby_name, lobby_mode, num_members, max_members]
		lobby_list.add_item(lobby_text)
		lobby_list.set_item_metadata(lobby_list.item_count - 1, lobby_id)


func _on_enet_host_button_pressed():
	NetworkManager.set_network_type(NetworkManager.MULTIPLAYER_NETWORK_TYPE.ENET)
	print("Start ENET Host")
	GameManager.start_multiplayer_host()


func _on_enet_join_button_pressed():
	NetworkManager.set_network_type(NetworkManager.MULTIPLAYER_NETWORK_TYPE.ENET)
	print("Join Enet Host")
	GameManager.start_multiplayer_client(0)
