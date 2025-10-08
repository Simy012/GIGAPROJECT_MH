extends CanvasLayer
class_name UIHandler

@export var inventory_gui: InventoryGUI

var ui_open: bool = false

func _setup_player_ui(player: Player):
	inventory_gui.inventory = player.inventory_component


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("left_click"):
		if not ui_open:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("toggle_inventory"):
		if inventory_gui.visible:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			inventory_gui.inventory_closed.emit()
			ui_open = false
		else:
			inventory_gui.inventory_opened.emit()
			ui_open = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
		
