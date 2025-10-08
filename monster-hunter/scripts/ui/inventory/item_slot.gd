extends PanelContainer

signal item_selected(item_stack: ItemStack)

@export var icon_texture: TextureRect
@export var quantity_label: Label
@export var rarity_panel: Panel
@export var item_name_label: Label

var item_stack: ItemStack

func _ready() -> void:
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func set_item_stack(stack: ItemStack) -> void:
	item_stack = stack
	update_display()

func update_display() -> void:
	if not item_stack or not item_stack.item:
		visible = false
		return
	
	visible = true
	var item = item_stack.item
	
	# Icon setzen
	if icon_texture and item.icon:
		icon_texture.texture = item.icon
	
	# Menge anzeigen
	if quantity_label:
		if item.can_stack():
			quantity_label.text = str(item_stack.quantity)
			quantity_label.visible = true
		else:
			quantity_label.visible = false
	
	# Seltenheit Farbe
	if rarity_panel:
		rarity_panel.self_modulate = item.get_rarity_color()
	
	# Item Name
	if item_name_label:
		item_name_label.text = item.item_name

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			item_selected.emit(item_stack)

# Für Tooltip Anzeige
func _on_mouse_entered() -> void:
	if item_stack and item_stack.item:
		show_tooltip()

func _on_mouse_exited() -> void:
	hide_tooltip()

func show_tooltip() -> void:
	# Hier könntest du einen Tooltip mit Details anzeigen
	pass

func hide_tooltip() -> void:
	pass
