extends CharacterBody3D
class_name Player

@export var player_id: int:
	set(id):
		player_id = id

var character_name: String = "playername_here"
var level: int = 1


# Components
@export var status_component: StatusEffectComponent
@export var camera_component: Camera3DComponent
@export var equipment_manager_component: EquipmentManager

@onready var inventory_component: Inventory = $InventoryComponent
@onready var movement_component: MovementComponent = $MovementComponent
@onready var level_component: LevelComponent = $LevelComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var player_input = $PlayerInput
@onready var server_synchronizer = $ServerSynchronizer


var is_local_player: bool = false

func _ready():
	pass

func setup_player():
	# Prüfe ob dieser Player uns gehört
	is_local_player = player_id == multiplayer.get_unique_id()
	
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
	
	if player_input:
		player_input.set_multiplayer_authority(player_id)

func _setup_local_player():
	# Kamera für lokalen Spieler aktivieren
	if camera_component:
		camera_component.set_current_camera(true)
		camera_component.set_process(true)
	
	# Input aktivieren
	if player_input:
		player_input.enabled = true
	
	load_data_from_save()


func _setup_remote_player():
	# Kamera für andere Spieler deaktivieren
	if camera_component:
		camera_component.set_current_camera(false)
		camera_component.set_process(false)
	
	# Input deaktivieren
	if player_input:
		player_input.enabled = false


func _physics_process(delta):
	# Nur Authority verarbeitet Physics
	if not multiplayer.is_server():
		return
	
	# Input holen
	var input_data: Dictionary = player_input.input_data
	var camera_basis: Basis = player_input.camera_global_basis
	
	if movement_component:
		movement_component.move(delta, input_data, camera_basis)



func _unhandled_input(event):
	if not is_local_player:
		return
	
	if camera_component:
		camera_component._process_unhandled_input(event)

#
# Lädt alle Daten vom Save und setzt dann entsprechend alle Werte im Player.
# Diese werden über Multiplayer Synchronizer gesynct 
func load_data_from_save():
	var data = SaveManager.load_game(SaveManager.current_slot)
	if data == {}:
		print("Error loading user Data")
	
	# Player Character:
	character_name = data["character"]["name"]
	level = data["character"]["level"]
	
	inventory_component.load_inventory(data["inventory"])
	# TODO load equipment, etc




###
### Hilfmethoden für weiterleitung an Components
###

#
# Health Component
#

func get_current_health() -> float:
	return health_component.get_current_health()

func get_max_health() -> float:
	return health_component.get_max_health()

func damage(damage: float, force_hide_damage: bool):
	health_component.damage(damage, force_hide_damage)

func heal(amount: float):
	health_component.heal(amount)


# 
# Movement Component
#

func get_current_stamina() -> float:
	return movement_component.get_current_stamina()

func get_max_stamina() -> float:
	return movement_component.get_max_stamina()


#
# Level Component
#

func add_experience(amount: float):
	level_component.add_experience(amount)

func remove_experience(amount: float):
	level_component.remove_experience(amount)

func reset_level():
	level_component.reset_level()

func get_current_experience() -> float:
	return level_component.get_current_experience()

func get_level_progress() -> float:
	return level_component.get_level_progress()

func get_level() -> int:
	return level_component.get_level()


# Status Effect Methoden (für Monster Attacks)
func apply_stun(duration: float):
	if status_component:
		status_component.apply_stun(duration)

func apply_slow(duration: float, slow_amount: float):
	if status_component:
		status_component.apply_slow(duration, slow_amount)
