extends Node3D
class_name Camera3DComponent

@export_group("Camera Settings")
@export var camera: Camera3D
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export var tilt_upper_limit := PI / 3.0
@export var tilt_lower_limit := -PI / 8.00
var _camera_input_direction := Vector2.ZERO


func process_camera_movement(delta):
	rotation.x += _camera_input_direction.y * delta
	rotation.x = clamp(rotation.x, tilt_lower_limit, tilt_upper_limit)
	rotation.y -= _camera_input_direction.x * delta
	
	_camera_input_direction = Vector2.ZERO


func set_current_camera(current: bool):
	camera.current = current


func _process_unhandled_input(event):
	var is_camera_motion := (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity
