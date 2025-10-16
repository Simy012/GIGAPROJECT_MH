extends Node3D

@onready var players_spawn_point = $Players
@export var ui_handler: UIHandler

func _ready():
	EventHandler.player_added.connect(_on_player_spawned_event)
	EventHandler.player_removed.connect(_on_player_despawned_event)
	
	GameManager.players_spawn_node = players_spawn_point


func _on_player_spawned(player: Player):
	EventHandler.player_added.emit(player)


func _on_player_despawned(player: Player):
	EventHandler.player_removed.emit(player)

func _on_player_spawned_event(player):
	player.setup_player()
	if int(player.name) == get_multiplayer_authority():
		ui_handler._setup_player_ui(player)

func _on_player_despawned_event(player: Player):
	if player.get_multiplayer_authority() == get_multiplayer_authority():
		SceneTransition.change_scene(GlobalData.MAIN_MENU_SCENE)
