@abstract
extends Node3D
class_name Scene

@export var sceneName: StringName
@export var player_spawn_point: Node3D

@abstract
func load_scene() -> void

@abstract
func unload_scene() -> void
