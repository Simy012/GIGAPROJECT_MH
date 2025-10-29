@abstract
extends Node3D
class_name Scene

# Hier kann man vielleicht noch signale einbauen für scene_loaded und scene_unloaded

@export var scene_name: StringName
@export var player_spawn_point: Node3D
@export var multiplayer_spawner: MultiplayerSpawner

func _ready():
	multiplayer_spawner.spawned.connect(_on_player_spawned)
	multiplayer_spawner.despawned.connect(_on_player_despawned)
	load_scene()

func _on_player_spawned(player: Player):
	EventHandler.player_added.emit(player)

func _on_player_despawned(player: Player):
	EventHandler.player_removed.emit(player)


@abstract
func load_scene() -> void


func unload_scene() -> void:
	for player in player_spawn_point.get_children():
		player_spawn_point.remove_child(player)
