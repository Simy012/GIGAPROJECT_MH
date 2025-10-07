extends CharacterBody3D
class_name Player

@export var player_id: int

# Components
@export var movement_component: MovementComponent
@export var status_component: StatusEffectComponent
@export var input_component: InputComponent
@export var camera_component: Camera3DComponent
@export var _skin: Node3D
@onready var multiplayer_sync = $CharacterSync

var move_speed: float = 10.0
var acceleration: float = 10.0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var jump_force: float = 6.0
var knockback_velocity: Vector3 = Vector3.ZERO
var _last_movement_direction := Vector3.BACK
@export var rotation_speed := 12.0


var is_local_player: bool = false

func _ready():
	# Prüfe ob dieser Player uns gehört
	is_local_player = is_multiplayer_authority()
	
	if is_local_player:
		print("Local player initialized: %s" % player_id)
		setup_local_player()
	else:
		print("Remote player initialized: %s" % player_id)
		setup_remote_player()
	
	# Components initialisieren
	if movement_component:
		movement_component.character = self
	
	if status_component:
		status_component.player = self

func setup_local_player():
	# Kamera für lokalen Spieler aktivieren
	if camera_component:
		camera_component.set_current_camera(true)
	
	# Input aktivieren
	if input_component:
		input_component.enabled = true
	
	# Mouse capture
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func setup_remote_player():
	# Kamera für andere Spieler deaktivieren
	if camera_component:
		camera_component.set_current_camera(false)
	
	# Input deaktivieren
	if input_component:
		input_component.enabled = false


func _physics_process(delta):
	# Nur Authority verarbeitet Physics
	if not is_multiplayer_authority():
		return
	
	
	# Input holen
	var input_data = input_component.get_input_data() if input_component else {}
	
	process_movement(delta, input_data)
	
	if camera_component:
		camera_component.process_camera_movement(delta)


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

		var y_velocity := velocity.y
		velocity.y = 0.0
		velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
		velocity.y = y_velocity + (-1 * gravity * delta)
	
	# --- Sprung ---
	var is_starting_jump: bool = false
	if "jump" in input_data and input_data["jump"] and is_on_floor():
		is_starting_jump = true
		velocity.y = jump_force
	
	# --- Schwerkraft ---
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		# Wenn auf Boden, Y-Velocity nicht zu groß
		if velocity.y < 0:
			velocity.y = -0.1
	
	# --- Knockback anwenden ---
	if knockback_velocity.length() > 0.1:
		velocity += knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector3.ZERO, delta * 10)
	
	# --- Bewegung anwenden ---
	move_and_slide()
	
	if move_direction.length() > 0.2:
		_last_movement_direction = move_direction
	var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
	_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)

	if is_starting_jump:
		_skin.jump()
	elif not is_on_floor() and velocity.y < 0:
		_skin.fall()
	elif is_on_floor():
		var ground_speed := velocity.length()
		if ground_speed > 0.0:
			_skin.move()
		else:
			_skin.idle()


func _unhandled_input(event):
	if not is_local_player:
		return
	
	if camera_component:
		camera_component._process_unhandled_input(event)


# Status Effect Methoden (für Monster Attacks)
func apply_stun(duration: float):
	if status_component:
		status_component.apply_stun(duration)

func apply_slow(duration: float, slow_amount: float):
	if status_component:
		status_component.apply_slow(duration, slow_amount)

func apply_knockback(direction: Vector3, force: float):
	if movement_component:
		movement_component.apply_knockback_force(direction, force)

func is_stunned() -> bool:
	return status_component.is_stunned() if status_component else false

func is_slowed() -> bool:
	return status_component.is_slowed() if status_component else false
