extends Control
class_name IngameMenu




func _on_continue_button_pressed():
	EventHandler.close_ingame_menu.emit()


func _on_save_button_pressed():
	save()


func _on_settings_button_pressed():
	pass # Replace with function body.


func _on_return_button_pressed():
	save()


func save():
	print("Save gamestate. Aktuell noch nicht implementiert")
	pass
