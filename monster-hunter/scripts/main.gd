extends Node3D
class_name MainNode

@export var ui_handler: UIHandler

@onready var scene_manager: SceneManager= $SceneManager

# ich muss
func _ready():
	EventHandler.player_added.connect(_on_player_spawned_event)
	EventHandler.player_removed.connect(_on_player_despawned_event)
	
	GameManager.main_node = self
	
	load_scene(GlobalData.LEVEL.NEXUS)


func load_scene(level_name: GlobalData.LEVEL) -> void:
	scene_manager.load_scene(level_name)


func get_player_spawn_point() -> Node3D:
	return scene_manager.get_player_spawn_point()

func _on_player_spawned_event(player: Player):
	player.setup_player()

func _on_player_despawned_event(player: Player):
	if player.get_multiplayer_authority() == get_multiplayer_authority():
		SceneTransition.change_scene(GlobalData.MAIN_MENU_SCENE)
