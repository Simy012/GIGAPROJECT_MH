extends Node3D

@onready var players_spawn_point = $Players # abändern in level scene
@export var ui_handler: UIHandler

@onready var level = $Level




func _ready():
	EventHandler.player_added.connect(_on_player_spawned_event)
	EventHandler.player_removed.connect(_on_player_despawned_event)
	
	GameManager.players_spawn_node = players_spawn_point



func load_scene(sceneName: StringName) -> void:
	
	pass





func _on_player_spawned(player: Player):
	EventHandler.player_added.emit(player)


func _on_player_despawned(player: Player):
	EventHandler.player_removed.emit(player)

func _on_player_spawned_event(player: Player):
	player.setup_player()

func _on_player_despawned_event(player: Player):
	if player.get_multiplayer_authority() == get_multiplayer_authority():
		SceneTransition.change_scene(GlobalData.MAIN_MENU_SCENE)
