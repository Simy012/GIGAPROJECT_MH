extends Control
class_name CharacterCreation


@onready var player_name_box: LineEdit = $VBoxContainer2/VBoxContainer/PlayerNameBox
@onready var create_button: Button = $VBoxContainer2/HBoxContainer/CreateButton


func _ready():
	create_button.disabled = true
	player_name_box.text = ""


func _on_create_button_pressed():
	SaveManager.create_new_save(player_name_box.text)
	SceneTransition.change_scene(GlobalData.GAME_MODE_SELECTION_SCENE)


func _on_return_button_pressed():
	SceneTransition.change_scene(GlobalData.CHARACTER_SELECTION_SCENE)


func _on_player_name_box_text_changed(new_text):
	if new_text != "":
		# Filter NAme nach schimpfwörtern etc
		create_button.disabled = false
	else:
		create_button.disabled = true
