extends Node
class_name MovementComponent

# Referenz zum Character
@export var character: CharacterBody3D
@export var camera_component: Camera3DComponent
@export var status_component: StatusEffectComponent
@export var _skin: Node3D
@export var _body: Node3D

@export var current_state: StringName = "Idle"
@export var last_state: StringName = "Idle"

var move_speed: float = 5.0
var sprint_speed: float = 1.8    # multiplikativ
var acceleration: float = 20.0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var jump_force: float = 6.0
var knockback_velocity: Vector3 = Vector3.ZERO
@export var _last_movement_direction := Vector3.BACK
@export var rotation_speed := 12.0


var is_sprinting: bool = false
var knockback_decay: float = 5.0

func _ready():
	current_state = "IDLE"
	pass


func _process(delta):
	animate_player()

func move(delta: float, input_data: Dictionary):
	var move_direction = get_movement_direction(delta, input_data)
	var target_angle = get_rotation_direction(move_direction)
	
	process_movement(delta, move_direction, target_angle)


# --- Movement Logik ---
func process_movement(delta: float, move_direction: Vector3, target_angle: float):
	
	var horizontal_velocity = Vector3(move_direction.x, 0, move_direction.z)
	character.velocity.x = lerp(character.velocity.x, horizontal_velocity.x, acceleration * delta)
	character.velocity.z = lerp(character.velocity.z, horizontal_velocity.z, acceleration * delta)
	
	# Vertikale Bewegung (Y) - wird von get_movement_direction gesetzt
	character.velocity.y = move_direction.y
	
	_body.global_rotation.y = lerp_angle(_body.global_rotation.y, target_angle, rotation_speed * delta)
	
	# --- Bewegung anwenden ---
	character.move_and_slide()
	
	
	if character.velocity.y > 0:
		current_state = "JUMP"
	elif not character.is_on_floor() and character.velocity.y < 0:
		current_state = "FALL"
	elif character.is_on_floor():
		var ground_speed := character.velocity.length()
		if ground_speed > 0.01:
			current_state = "RUN"
		else:
			current_state = "IDLE"



func get_movement_direction(delta: float, input_data: Dictionary) -> Vector3:
	if is_stunned():
		# Wenn betäubt, kein Input und kein Move
		input_data = {}
	
	# --- Input Richtung holen ---
	var input_dir: Vector2 = Vector2.ZERO
	if "move_direction" in input_data:
		input_dir = input_data["move_direction"]
	
	
	# --- Kamera-Relative Richtung berechnen ---
	var horizontal_direction := Vector3.ZERO
	if camera_component and camera_component.camera:
		var forward := camera_component.camera.global_basis.z
		var right := camera_component.camera.global_basis.x
		horizontal_direction = forward * input_dir.y + right * input_dir.x
		horizontal_direction.y = 0.0
		horizontal_direction = horizontal_direction.normalized()
	
	var applying_speed = move_speed
	if "sprint" in input_data:
		if input_data["sprint"]:
			applying_speed *= sprint_speed
	
	horizontal_direction *= applying_speed
	
	var vertical_velocity: float = character.velocity.y
	# --- Sprung ---
	var is_starting_jump: bool = false
	if "jump" in input_data and input_data["jump"] and character.is_on_floor():
		print("WANT TO JUMP")
		is_starting_jump = true
		vertical_velocity = jump_force
	
	# --- Schwerkraft ---
	if not character.is_on_floor():
		print("player: ",multiplayer.get_unique_id(), " is in air")
		vertical_velocity -= gravity * delta
	else:
		# Wenn auf Boden, Y-Velocity nicht zu groß
		if vertical_velocity < 0:
			vertical_velocity = -0.1
	
	""" --- Knockback anwenden ---
	if knockback_velocity.length() > 0.1:
		move_direction += knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector3.ZERO, delta * 10)
	"""
	
	var move_direction := Vector3(
		horizontal_direction.x,
		vertical_velocity,
		horizontal_direction.z
	)
	
	return move_direction


func get_rotation_direction(move_direction: Vector3) -> float:
	# Nur horizontale Komponente für Rotation verwenden
	var horizontal_move := Vector3(move_direction.x, 0, move_direction.z)
	
	if horizontal_move.length() > 0.2:
		_last_movement_direction = horizontal_move.normalized()
	
	var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
	
	return target_angle


func is_stunned() -> bool:
	return status_component.is_stunned() if status_component else false

func is_slowed() -> bool:
	return status_component.is_slowed() if status_component else false


func animate_player():
	if current_state == last_state:
		return
	_skin.animate(current_state)
