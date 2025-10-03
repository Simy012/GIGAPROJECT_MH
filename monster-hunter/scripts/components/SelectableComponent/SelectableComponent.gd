extends Node
class_name SelectableComponent

signal selected()
signal deselected()

var old_value: bool = false
var is_selected: bool = false

func select():
	is_selected = true
	emit_signal("selected")
	old_value = true

func deselect():
	is_selected = false
	emit_signal("deselected")
	old_value = false
