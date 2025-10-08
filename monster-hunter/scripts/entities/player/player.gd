extends CharacterBody3D
class_name Player

@export var player_id: int

# Components
@export var movement_component: MovementComponent
@export var status_component: StatusEffectComponent
@export var input_component: InputComponent
@export var camera_component: Camera3DComponent
@export var inventory_component: Inventory
@export var equipment_manager_component: EquipmentManager
@onready var multiplayer_sync = $CharacterSync


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
	
	if movement_component:
		movement_component.process_movement(delta, input_data)
	
	if camera_component:
		camera_component.process_camera_movement(delta)


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
