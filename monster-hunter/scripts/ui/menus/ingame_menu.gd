extends Control
class_name IngameMenu




func _on_continue_button_pressed():
	EventHandler.close_ingame_menu.emit()


func _on_save_button_pressed():
	save()


func _on_settings_button_pressed():
	# Hier child hinzuifügen mit neuen settnigs und dann escape event abfangen und erstmal nur zum ingame menü zurück
	pass # Replace with function body.


func _on_return_button_pressed():
	save()
	SceneTransition.change_scene(GlobalData.MAIN_MENU_SCENE)


func save():
	EventHandler.save_game.emit()
	pass
