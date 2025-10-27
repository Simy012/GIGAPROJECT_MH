extends Node
class_name SceneManager

var current_scene: Scene



func load_scene(scene: GlobalData.LEVEL):
	if current_scene:
		current_scene.unload_scene()
		current_scene.call_deferred("queue_free")
	
	current_scene = GlobalData.get_level_instance(scene)
	
	add_child(current_scene)


func get_player_spawn_point() -> Node3D:
	return current_scene.player_spawn_point
