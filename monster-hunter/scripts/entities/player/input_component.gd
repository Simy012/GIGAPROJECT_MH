extends Node
class_name InputComponent

var enabled: bool = false

func get_input_data() -> Dictionary:
	if not enabled:
		return {}
	
	var input_data = {}
	
	# Movement Direction
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	input_data["move_direction"] = input_dir
	
	# Sprint
	input_data["sprint"] = Input.is_action_pressed("sprint")
	
	# Jump
	input_data["jump"] = Input.is_action_just_pressed("jump")
	
	# Attack (für später)
	#input_data["attack"] = Input.is_action_just_pressed("attack")
	
	return input_data
