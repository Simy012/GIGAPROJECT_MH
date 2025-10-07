extends Node
class_name MovementComponent

# Referenz zum Character
var character: Player


# Movement Stats
@export_group("Movement")
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var jump_velocity: float = 6.0
@export var acceleration: float = 10.0
@export var deceleration: float = 15.0
@export var air_control: float = 0.3

@export_group("Stamina")
@export var max_stamina: float = 100.0
@export var stamina_regen_rate: float = 20.0
@export var sprint_stamina_cost: float = 15.0
@export var jump_stamina_cost: float = 20.0

# State
var current_stamina: float = 100.0
var is_sprinting: bool = false
var knockback_velocity: Vector3 = Vector3.ZERO
var knockback_decay: float = 5.0

# Gravity
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	current_stamina = max_stamina

func process_movement(delta: float, input_data: Dictionary):
	if not character:
		return
	
	# Status Effects checken
	var is_stunned = character.is_stunned() if character.has_method("is_stunned") else false
	var is_slowed = character.is_slowed() if character.has_method("is_slowed") else false
	
	# Wenn stunned, keine Bewegung
	if is_stunned:
		apply_gravity(delta)
		apply_knockback(delta)
		character.move_and_slide()
		return
	
	# Stamina regenerieren
	regenerate_stamina(delta)
	
	# Gravity
	apply_gravity(delta)
	
	# Knockback anwenden (z.B. von Monster-Angriffen)
	apply_knockback(delta)
	
	# Jump
	if input_data.get("jump", false) and character.is_on_floor():
		try_jump()
	
	# Movement Direction
	var input_dir = input_data.get("move_direction", Vector2.ZERO)
	var direction = get_movement_direction(input_dir)
	
	# Sprint
	var want_sprint = input_data.get("sprint", false)
	update_sprint_state(want_sprint, direction.length() > 0)
	
	# Speed berechnen
	var target_speed = get_current_speed(is_slowed)
	
	# Bewegung anwenden
	if direction.length() > 0:
		print(direction)
		var target_velocity = direction * target_speed
		character.velocity.x = lerp(character.velocity.x, target_velocity.x, acceleration * delta)
		character.velocity.z = lerp(character.velocity.z, target_velocity.z, acceleration * delta)
		
		#  Jetzt in Bewegungsrichtung ausrichten
		var target_rotation = atan2(-direction.x, -direction.z)
		character.rotation.y = lerp_angle(character.rotation.y, target_rotation, 2.0 * delta)
	else:
		# Deceleration
		character.velocity.x = lerp(character.velocity.x, 0.0, deceleration * delta)
		character.velocity.z = lerp(character.velocity.z, 0.0, deceleration * delta)
	
	character.move_and_slide()


func apply_gravity(delta: float):
	if not character.is_on_floor():
		character.velocity.y -= gravity * delta

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


func get_current_speed(is_slowed: bool) -> float:
	var base_speed = sprint_speed if is_sprinting else walk_speed
	
	# Slow Effect anwenden
	if is_slowed:
		var slow_multiplier = character.status_component.get_slow_multiplier()
		base_speed *= slow_multiplier
	
	return base_speed

func update_sprint_state(want_sprint: bool, is_moving: bool):
	# Sprint nur wenn Stamina vorhanden und bewegend
	if want_sprint and is_moving and current_stamina > 0:
		is_sprinting = true
	else:
		is_sprinting = false

func try_jump():
	if current_stamina >= jump_stamina_cost:
		character.velocity.y = jump_velocity
		current_stamina -= jump_stamina_cost

func regenerate_stamina(delta: float):
	# Keine Regen während Sprint
	if is_sprinting:
		current_stamina -= sprint_stamina_cost * delta
		current_stamina = max(0, current_stamina)
	else:
		current_stamina += stamina_regen_rate * delta
		current_stamina = min(max_stamina, current_stamina)

func apply_knockback_force(direction: Vector3, force: float):
	#Von außen aufgerufen z.B. bei Monster-Attacke
	knockback_velocity = direction.normalized() * force

func apply_knockback(delta: float):
	if knockback_velocity.length() > 0.1:
		character.velocity += knockback_velocity * delta
		knockback_velocity = knockback_velocity.lerp(Vector3.ZERO, knockback_decay * delta)
	else:
		knockback_velocity = Vector3.ZERO

func get_stamina_percent() -> float:
	return current_stamina / max_stamina
