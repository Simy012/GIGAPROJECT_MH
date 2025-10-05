extends Node3D

@onready var players_spawn_point = $Players

func _ready():
	if MultiplayerManager.multiplayer_mode_enabled:
		NetworkManager.players_spawn_node = players_spawn_point
