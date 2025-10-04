extends ActionNode


const SPEED: float = 3.0
var rotation_speed: float = 15.0

var _movement_class: MovementState 
var _movement_manager: MovementStateManager

var _last_movement_direction: Vector3 = Vector3.ZERO

func _init() -> void:
	self.ACTION_ID = "MOVE"
	self.IS_LAYERED = true

func _ready() -> void:
	var character = get_parent().get_parent()
	_movement_class = character.find_child("GroundedMovement", false)
	if !_movement_class:
		_movement_manager = character.find_child("MovementManager", false)
		_movement_class = _movement_manager.find_child("GroundedMovement", false)


func can_play() -> bool:
	if !is_enabled:
		return false
	if _movement_manager and _movement_manager.active_state.name != "GroundedMovement":
		return false
	return true

func play(_params: Dictionary = {}) -> void:
	if _params.has("input_direction"):
		_movement_class.move(_params["input_direction"], SPEED)
		if _params["input_direction"] != Vector3.ZERO and model:
			if _params["input_direction"].length() > 0.2:
				_last_movement_direction = _params["input_direction"]
			var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
			model.global_rotation.y = lerp_angle(model.rotation.y, target_angle, rotation_speed * _params["delta"])
			model.animate("MOVE")
		else:
			model.animate("IDLE")
		
		
		
		super.play()

func stop() -> void:
	if _movement_class.input_vector != Vector3.ZERO:
		_movement_class.move(Vector3.ZERO, 0)
		
		if model:
			model.animate("IDLE")
		
		super.stop()
