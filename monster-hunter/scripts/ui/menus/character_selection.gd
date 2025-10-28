extends Control
class_name CharacterSelection

@onready var character_list = $CharacterListControl/ScrollContainer/CharacterList # eine vbox in einem scrollcontainer
@onready var select_button = $Buttons/SelectButton
@onready var create_button = $Buttons/CreateButton
@onready var delete_button = $Buttons/DeleteButton
@onready var back_button = $Buttons/BackButton


var selected_slot: int = -1
var characters : Dictionary = {}


func _ready():
	load_characters()


func load_characters():
	for btn in character_list.get_children():
		btn.queue_free()
	characters.clear()
	
	var slots = SaveManager.get_all_slots()
	for slot in slots:
		if slot["exists"]:
			characters[slot["slot_id"]] = SaveManager.load_game(slot["slot_id"])
	
	print("all Characters: ", characters)
	for character in characters:
		print("character dict:", characters[character]) 
		var char_name = characters[character]["character"]["name"]
		var char_level = characters[character]["character"]["level"]
		print("char_name: ", char_name)
		print("char_level: ", char_level)
		_add_character_button(int(character), char_name, char_level)


func _add_character_button(slot_id: int, char_name: String, level: float):
	var btn = Button.new()
	btn.text = str(slot_id + 1) + ".  " + char_name + "   LVL: " + str(level)
	btn.focus_mode = Control.FOCUS_ALL
	btn.connect("pressed", Callable(self, "_on_character_button_pressed").bind(slot_id))
	character_list.add_child(btn)


func _on_character_button_pressed(slot_id: int):
	if selected_slot == slot_id:
		_on_select_button_pressed()
		return
	selected_slot = slot_id
	select_button.disabled = false
	delete_button.disabled = false
	
	print("Selected slot: ", selected_slot)




func _on_select_button_pressed():
	if selected_slot != -1:
		print("Character selected: ", selected_slot)
		SceneTransition.change_scene(GlobalData.GAME_MODE_SELECTION_SCENE)
	else:
		print("Kein Charakter ausgewählt!")


func _on_create_button_pressed():
	SceneTransition.change_scene(GlobalData.CHARACTER_CREATION_SCENE)


func _on_delete_button_pressed():
	if selected_slot == -1:
		print("Kein Charakter zum Löschen ausgewählt.")
		return
	
	SaveManager.delete_slot(selected_slot)
	selected_slot = -1
	select_button.disabled = true
	delete_button.disabled = true
	load_characters()


func _on_back_button_pressed():
	SceneTransition.change_scene(GlobalData.MAIN_MENU_SCENE)
