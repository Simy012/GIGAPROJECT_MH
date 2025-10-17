extends CanvasLayer
class_name UIHandler

@export var inventory_gui: InventoryGUI
@export var ingame_menu: IngameMenu
@export var quest_menu: QuestMenu

var open_uis: Array[CanvasItem] = []


func _ready() -> void:
	_hide_all_uis()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	EventHandler.close_ingame_menu.connect(_close_ui.bind(ingame_menu))


func _setup_player_ui(player: Player) -> void:
	inventory_gui.inventory = player.inventory_component


func _input(event: InputEvent) -> void:
	# Wenn das Ingame-Menü offen ist → blockiere alle anderen UI-Inputs
	if _is_ingame_menu_open():
		if event.is_action_pressed("toggle_ingame_menu"):
			_handle_ingame_menu_toggle()
		return

	if event.is_action_pressed("toggle_inventory"):
		_toggle_exclusive_ui(inventory_gui)
	elif event.is_action_pressed("toggle_quest_menu") and quest_menu:
		_toggle_exclusive_ui(quest_menu)
	elif event.is_action_pressed("toggle_ingame_menu"):
		_handle_ingame_menu_toggle()
	elif event.is_action_pressed("left_click"):
		if open_uis.is_empty():
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# --- CORE UI MANAGEMENT --- #

# Öffnet ein UI exklusiv (schließt alle anderen)
func _toggle_exclusive_ui(ui_element: CanvasItem) -> void:
	if ui_element.visible:
		_close_ui(ui_element)
	else:
		_close_all_uis()
		_open_ui(ui_element)


func _handle_ingame_menu_toggle() -> void:
	if _is_ingame_menu_open():
		_close_ui(ingame_menu)
	elif not open_uis.is_empty():
		# Wenn andere UIs offen sind → alle schließen
		_close_all_uis()
	else:
		# Wenn nichts offen ist → öffne das Ingame-Menü
		_open_ui(ingame_menu)


func _is_ingame_menu_open() -> bool:
	return ingame_menu and ingame_menu.visible


func _open_ui(ui_element: CanvasItem) -> void:
	if not open_uis.has(ui_element):
		open_uis.append(ui_element)
	ui_element.show()
	_update_mouse_mode()
	_on_ui_opened(ui_element)


func _close_ui(ui_element: CanvasItem) -> void:
	if open_uis.has(ui_element):
		open_uis.erase(ui_element)
	ui_element.hide()
	_update_mouse_mode()
	_on_ui_closed(ui_element)


func _close_all_uis() -> void:
	for ui in open_uis.duplicate():
		_close_ui(ui)


func _hide_all_uis() -> void:
	for ui in [inventory_gui, ingame_menu, quest_menu]:
		if ui:
			ui.hide()
	open_uis.clear()


func _update_mouse_mode() -> void:
	if open_uis.is_empty():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


# --- OPTIONAL CALLBACKS --- #

func _on_ui_opened(ui_element: CanvasItem) -> void:
	match ui_element:
		inventory_gui:
			inventory_gui.inventory_opened.emit()
		ingame_menu:
			# Beispiel: get_tree().paused = true
			pass
		quest_menu:
			quest_menu.menu_opened.emit()


func _on_ui_closed(ui_element: CanvasItem) -> void:
	match ui_element:
		inventory_gui:
			inventory_gui.inventory_closed.emit()
		ingame_menu:
			# Beispiel: get_tree().paused = false
			pass
		quest_menu:
			quest_menu.menu_closed.emit()
