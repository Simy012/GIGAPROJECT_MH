@abstract
extends Node3D
class_name Scene

@export var scene_name: StringName
@export var player_spawn_point: Node3D

func _ready():
	load_scene()



@abstract
func load_scene() -> void

@abstract
func unload_scene() -> void
