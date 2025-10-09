extends MultiplayerSynchronizer


var enabled: bool = false

@export var input_data: Dictionary

func _process(delta):
	if not enabled:
		return
	
	input_data = {}
	
	# Movement Direction
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	input_data["move_direction"] = input_dir
	
	# Sprint
	input_data["sprint"] = Input.is_action_pressed("sprint")
	
	# Jump
	input_data["jump"] = Input.is_action_just_pressed("jump")
