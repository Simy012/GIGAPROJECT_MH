extends MultiplayerSynchronizer


var enabled: bool = false

@export var movement_component: MovementComponent
@export var move_direction: Vector3
@export var target_angle: float 


func _process(delta):
	print("playerInput multi authority: ",get_multiplayer_authority(), " and mutlitplayer unique id: ", multiplayer.get_unique_id())
	if not enabled:
		return
	
	var input_data: Dictionary = {}
	
	# Movement Direction
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	input_data["move_direction"] = input_dir
	
	# Sprint
	input_data["sprint"] = Input.is_action_pressed("sprint")
	
	# Jump
	input_data["jump"] = Input.is_action_just_pressed("jump")
	
	# Berechne move_direction:
	move_direction = movement_component.get_movement_direction(delta, input_data)
	target_angle = movement_component.get_rotation_direction(move_direction)
	
	print("PlayerID: ",get_multiplayer_authority()," MoveDirection: ", move_direction)
