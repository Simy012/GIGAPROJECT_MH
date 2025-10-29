extends Scene


func load_scene() -> void:
	print("Lade Szene: ", scene_name)


func unload_scene() -> void:
	super.unload_scene()
	print("Entlade Szene: ", scene_name)
