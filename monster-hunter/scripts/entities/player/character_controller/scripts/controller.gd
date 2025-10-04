extends Node
class_name Controller

## utilizes ActionNodes to controll a controllable node

func _ready():
	EventHandler.player_added.connect(player_added)


@export var controlled_obj: Node:
	set(value):
		controlled_obj = value
		_on_controlled_obj_change()


func _on_controlled_obj_change():
	pass



func player_added(player: Player):
	controlled_obj = player 
