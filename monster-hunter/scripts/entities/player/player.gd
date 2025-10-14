extends CharacterBody3D
class_name Player

@export var player_id: int

# Components
@export var movement_component: MovementComponent
@export var status_component: StatusEffectComponent
@export var camera_component: Camera3DComponent
@export var inventory_component: Inventory
@export var equipment_manager_component: EquipmentManager
@onready var multiplayer_sync: MultiplayerSynchronizer = $CharacterSync
@onready var health_component: HealthComponent = $HealthComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var player_input = $PlayerInput


var is_local_player: bool = false


func setup_player():
	# Prüfe ob dieser Player uns gehört
	is_local_player = is_multiplayer_authority()
	
	if is_local_player:
		print("Local player initialized: %s" % player_id)
		_setup_local_player()
	else:
		print("Remote player initialized: %s" % player_id)
		_setup_remote_player()
	
	# Components initialisieren
	if movement_component:
		movement_component.character = self
	
	if status_component:
		status_component.player = self

func _setup_local_player():
	# Kamera für lokalen Spieler aktivieren
	if camera_component:
		camera_component.set_current_camera(true)
		camera_component.set_process(true)
	
	# Input aktivieren
	if player_input:
		player_input.enabled = true
	
	if movement_component:
		movement_component.set_process(true)

func _setup_remote_player():
	# Kamera für andere Spieler deaktivieren
	if camera_component:
		camera_component.set_current_camera(false)
		camera_component.set_process(false)
	
	# Input deaktivieren
	if player_input:
		player_input.enabled = false
	
	if movement_component:
		movement_component.set_process(false)

func _physics_process(delta):
	# Nur Authority verarbeitet Physics
	if not multiplayer.is_server():
		return
	
	# Input holen
	var move_direction = player_input.move_direction
	var target_angle = player_input.target_angle
	
	if get_multiplayer_authority() != 1:
		print("CLient INPUT DATA BEI HOST IST: ", move_direction)
	
	if movement_component:
		movement_component.process_movement(delta, move_direction, target_angle)
	
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
