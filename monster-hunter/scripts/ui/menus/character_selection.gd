extends Control
class_name CharacterSelection

@onready var character_list = $CharacterListControl/ScrollContainer/CharacterList # eine vbox in einem scrollcontainer
@onready var select_button = $Buttons/SelectButton
@onready var create_button = $Buttons/CreateButton
@onready var delete_button = $Buttons/DeleteButton
@onready var back_button = $Buttons/BackButton


var selected_character: Button
var characters : Array[Button] = []

var character_info : Dictionary = {}

func _ready():
	load_characters()


func load_characters():
	character_list.queue_free_children()  # Liste leeren
	characters.clear()
	
	character_info = SaveManager.get_all_characters()
	
	


func _add_character_button(char_name: String):
	var btn = Button.new()
	btn.text = char_name
	btn.focus_mode = Control.FOCUS_CLICK
	btn.connect("pressed", Callable(self, "_on_character_button_pressed").bind(char_name))
	character_list.add_child(btn)


func _on_character_button_pressed(char_name: String):
	for child in character_list.get_children():
		if child is Button:
			child.add_theme_color_override("font_color", Color.WHITE)
	var btn = character_list.get_node_or_null(char_name)
	selected_character = btn
	print("Selected character: ", char_name)
	_highlight_selected_button(char_name)


func _highlight_selected_button(selected: String):
	for child in character_list.get_children():
		if child is Button:
			if child.text == selected:
				child.add_theme_color_override("font_color", Color.CYAN)
			else:
				child.add_theme_color_override("font_color", Color.WHITE)


func _on_select_button_pressed():
	if selected_character:
		print("Character selected: ", selected_character)
		SceneTransition.change_scene(GlobalData.GAME_SCENE)
	else:
		print("Kein Charakter ausgewählt!")


func _on_create_button_pressed():
	SceneTransition.change_scene(GlobalData.CHARACTER_CREATION_SCENE)


func _on_delete_button_pressed():
	if not selected_character:
		print("Kein Charakter zum Löschen ausgewählt.")
		return
	
		SaveManager.delete_slot(int(selected_character.name))
		load_characters()
	else:
		print("Datei existiert nicht.")


func _on_back_button_pressed():
	SceneTransition.change_scene(GlobalData.MAIN_MENU_SCENE)
