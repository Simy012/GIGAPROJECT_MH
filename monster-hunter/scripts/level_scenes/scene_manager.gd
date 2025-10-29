extends Node
class_name SceneManager

var current_scene: Scene

signal scene_loaded()



func load_scene(scene: GlobalData.LEVEL):
	if current_scene:
		current_scene.unload_scene()
		current_scene.call_deferred("queue_free")
		await get_tree().process_frame
		print("nach await process frame, currentScene: ", current_scene)
	
	current_scene = GlobalData.get_level_instance(scene)
	
	add_child(current_scene)
	scene_loaded.emit()


func get_player_spawn_point() -> Node3D:
	return current_scene.player_spawn_point
