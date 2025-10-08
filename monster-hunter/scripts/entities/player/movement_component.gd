extends Node
class_name MovementComponent

# Referenz zum Character
@export var character: CharacterBody3D
@export var camera_component: Camera3DComponent
@export var status_component: StatusEffectComponent
@export var _skin: Node3D


var move_speed: float = 10.0
var acceleration: float = 10.0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var jump_force: float = 6.0
var knockback_velocity: Vector3 = Vector3.ZERO
var _last_movement_direction := Vector3.BACK
@export var rotation_speed := 12.0

@export_group("Stamina")
@export var max_stamina: float = 100.0
@export var stamina_regen_rate: float = 20.0
@export var sprint_stamina_cost: float = 15.0
@export var jump_stamina_cost: float = 20.0

# State
var current_stamina: float = 100.0
var is_sprinting: bool = false
var knockback_decay: float = 5.0

func _ready():
	current_stamina = max_stamina

# --- Movement Logik ---
func process_movement(delta: float, input_data: Dictionary):
	if is_stunned():
		# Wenn betäubt, kein Input und kein Move
		input_data = {}
	
	# --- Input Richtung holen ---
	var input_dir: Vector2 = Vector2.ZERO
	if "move_direction" in input_data:
		input_dir = input_data["move_direction"]
	
	var move_direction: Vector3
	# --- Kamera-Relative Richtung berechnen ---
	if camera_component and camera_component.camera:
		var forward := camera_component.camera.global_basis.z
		var right := camera_component.camera.global_basis.x
		move_direction = forward * input_dir.y + right * input_dir.x
		move_direction.y = 0.0
		move_direction = move_direction.normalized()

		var y_velocity := character.velocity.y
		character.velocity.y = 0.0
		character.velocity = character.velocity.move_toward(move_direction * move_speed, acceleration * delta)
		character.velocity.y = y_velocity + (-1 * gravity * delta)
	
	# --- Sprung ---
	var is_starting_jump: bool = false
	if "jump" in input_data and input_data["jump"] and character.is_on_floor():
		is_starting_jump = true
		character.velocity.y = jump_force
	
	# --- Schwerkraft ---
	if not character.is_on_floor():
		character.velocity.y -= gravity * delta
	else:
		# Wenn auf Boden, Y-Velocity nicht zu groß
		if character.velocity.y < 0:
			character.velocity.y = -0.1
	
	# --- Knockback anwenden ---
	if knockback_velocity.length() > 0.1:
		character.velocity += knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector3.ZERO, delta * 10)
	
	# --- Bewegung anwenden ---
	character.move_and_slide()
	
	if move_direction.length() > 0.2:
		_last_movement_direction = move_direction
	var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
	_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)

	if is_starting_jump:
		_skin.jump()
	elif not character.is_on_floor() and character.velocity.y < 0:
		_skin.fall()
	elif character.is_on_floor():
		var ground_speed := character.velocity.length()
		if ground_speed > 0.0:
			_skin.move()
		else:
			_skin.idle()


func is_stunned() -> bool:
	return status_component.is_stunned() if status_component else false

func is_slowed() -> bool:
	return status_component.is_slowed() if status_component else false


func get_movement_direction(input_dir: Vector2) -> Vector3:
	if not character.camera_component or not character.camera_component.camera:
		push_warning("MovementComponent: Keine Kamera referenziert!")
		return Vector3.ZERO
	
	# Get Camera for relative movement direction
	var camera = character.camera_component.camera
	
	#var camera_basis = camera.global_transform.basis
	var forward = -camera.global_basis.z
	var right = camera.global_basis.x
	
	var move_direction = forward * input_dir.y + right * input_dir.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	return move_direction


func regenerate_stamina(delta: float):
	# Keine Regen während Sprint
	if is_sprinting:
		current_stamina -= sprint_stamina_cost * delta
		current_stamina = max(0, current_stamina)
	else:
		current_stamina += stamina_regen_rate * delta
		current_stamina = min(max_stamina, current_stamina)



func get_stamina_percent() -> float:
	return current_stamina / max_stamina
