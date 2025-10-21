extends Control
class_name CharacterCreation


func _on_create_button_pressed():
	SceneTransition.change_scene(GlobalData.MAIN_GAME_SCENE)


func _on_return_button_pressed():
	SceneTransition.change_scene(GlobalData.CHARACTER_SELECTION_SCENE)
