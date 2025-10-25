extends Node
class_name MovementComponent

# --- Referenzen ---
@export var character: CharacterBody3D
@export var camera_component: Camera3DComponent
@export var status_component: StatusEffectComponent
@export var _skin: Node3D
@export var _body: Node3D

# --- Movement Variablen ---
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
var knockback_decay: float = 5.0

# --- 🧠 Stamina System ---
@export_group("Stamina Settings")
@export var max_stamina: float = 100.0
@export var stamina: float = 100.0
@export var stamina_regen_rate: float = 15.0       # pro Sekunde
@export var sprint_stamina_drain: float = 20.0     # pro Sekunde
@export var jump_stamina_cost: float = 20.0
@export var min_stamina_to_sprint: float = 10.0    # Mindestwert zum Starten
@export var stamina_regen_cooldown: float = 0.8 # Time till stamina regen starts
var stamina_regen_timer = Timer.new()
var can_regen_stamina: bool = true
signal stamina_changed(current: float, max: float)

var is_sprinting: bool = false


func _ready():
	current_state = "IDLE"
	emit_signal("stamina_changed", stamina, max_stamina)
	stamina_regen_timer.autostart = false
	stamina_regen_timer.one_shot = true
	stamina_regen_timer.timeout.connect(_on_stamina_timer_timeout)
	add_child(stamina_regen_timer)

func _process(delta):
	animate_player()
	_regen_stamina(delta)


# --- Hauptbewegung ---
func move(delta: float, input_data: Dictionary, camera_basis: Basis):
	var move_direction = get_movement_direction(delta, input_data, camera_basis)
	var target_angle = get_rotation_direction(move_direction)
	process_movement(delta, move_direction, target_angle)


# --- Bewegung Logik ---
func process_movement(delta: float, move_direction: Vector3, target_angle: float):
	var horizontal_velocity = Vector3(move_direction.x, 0, move_direction.z)
	character.velocity.x = lerp(character.velocity.x, horizontal_velocity.x, acceleration * delta)
	character.velocity.z = lerp(character.velocity.z, horizontal_velocity.z, acceleration * delta)
	character.velocity.y = move_direction.y
	_body.global_rotation.y = lerp_angle(_body.global_rotation.y, target_angle, rotation_speed * delta)
	character.move_and_slide()

	if character.velocity.y > 0:
		current_state = "JUMP"
	elif not character.is_on_floor() and character.velocity.y < 0:
		current_state = "FALL"
	elif character.is_on_floor():
		var ground_speed := character.velocity.length()
		if ground_speed > 0.01:
			current_state = "MOVE" if not is_sprinting else "RUN"
		else:
			current_state = "IDLE"


# --- Richtung & Input ---
func get_movement_direction(delta: float, input_data: Dictionary, camera_basis: Basis) -> Vector3:
	if is_stunned():
		input_data = {}

	var input_dir: Vector2 = Vector2.ZERO
	if "move_direction" in input_data:
		input_dir = input_data["move_direction"]

	var forward := camera_basis.z
	var right := camera_basis.x
	var horizontal_direction := (forward * input_dir.y + right * input_dir.x).normalized()

	# --- Sprint prüfen ---
	is_sprinting = false
	var applying_speed := move_speed
	if "sprint" in input_data and input_data["sprint"] and stamina > min_stamina_to_sprint:
		is_sprinting = true
		applying_speed *= sprint_speed
		_drain_stamina(delta)
	
	horizontal_direction *= applying_speed

	# --- Sprung ---
	var vertical_velocity: float = character.velocity.y
	if "jump" in input_data and input_data["jump"] and character.is_on_floor() and stamina > jump_stamina_cost:
		vertical_velocity = jump_force
		_jump_stamina()

	# --- Schwerkraft ---
	if not character.is_on_floor():
		vertical_velocity -= gravity * delta
	else:
		if vertical_velocity < 0:
			vertical_velocity = -0.1

	return Vector3(horizontal_direction.x, vertical_velocity, horizontal_direction.z)


func get_rotation_direction(move_direction: Vector3) -> float:
	var horizontal_move := Vector3(move_direction.x, 0, move_direction.z)
	if horizontal_move.length() > 0.2:
		_last_movement_direction = horizontal_move.normalized()
	return Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)


# --- Stamina Logik ---
func _drain_stamina(delta: float):
	stamina = clamp(stamina - sprint_stamina_drain * delta, 0, max_stamina)
	can_regen_stamina = false
	emit_signal("stamina_changed", stamina, max_stamina)
	if stamina <= 0.1:
		is_sprinting = false
	stamina_regen_timer.start(stamina_regen_cooldown)

func _regen_stamina(delta: float):
	if is_sprinting or not can_regen_stamina:
		return
	if stamina < max_stamina:
		stamina = min(max_stamina, stamina + stamina_regen_rate * delta)
		emit_signal("stamina_changed", stamina, max_stamina)

func _jump_stamina():
	stamina = clamp(stamina - jump_stamina_cost, 0, max_stamina)

func _on_stamina_timer_timeout():
	can_regen_stamina = true

func get_current_stamina() -> float:
	return stamina

func get_max_stamina() -> float:
	return max_stamina


# --- Utils ---
func is_stunned() -> bool:
	return status_component.is_stunned() if status_component else false

func is_slowed() -> bool:
	return status_component.is_slowed() if status_component else false

func animate_player():
	if current_state == last_state:
		return
	last_state = current_state
	_skin.animate(current_state)
