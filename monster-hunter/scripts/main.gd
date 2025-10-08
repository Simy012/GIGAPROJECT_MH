extends Node3D

@onready var players_spawn_point = $Players
@export var ui_handler: UIHandler

func _ready():
	if MultiplayerManager.multiplayer_mode_enabled:
		NetworkManager.players_spawn_node = players_spawn_point


func _on_player_spawned(player: Player):
	EventHandler.player_added.emit(player)
	if player.get_multiplayer_authority() == get_multiplayer_authority():
		ui_handler._setup_player_ui(player)

func _on_player_despawned(player: Player):
	EventHandler.player_removed.emit(player)
	if player.get_multiplayer_authority() == get_multiplayer_authority():
		SceneTransition.change_scene(GlobalData.MAIN_MENU_SCENE)
