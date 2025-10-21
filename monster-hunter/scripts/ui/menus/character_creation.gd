extends Control
class_name CharacterCreation


func _on_create_button_pressed():
	SaveManager.create_new_save()
	SceneTransition.change_scene(GlobalData.GAME_MODE_SELECTION_SCENE)


func _on_return_button_pressed():
	SceneTransition.change_scene(GlobalData.CHARACTER_SELECTION_SCENE)
