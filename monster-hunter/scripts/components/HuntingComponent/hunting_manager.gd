extends Node

signal mission_selected(mission: HuntingMission)
signal mission_started(mission: HuntingMission)
signal mission_completed(mission: HuntingMission)
signal mission_canceled(mission: HuntingMission)
signal mission_failed(mission: HuntingMission)

var current_mission: HuntingMission
var hunting_catalog: HuntingCatalog = preload("res://resources/hunting/hunting_catalog.tres")

var timer_to_start: Timer # Timer bis Mission nach dem auswählen startet
const WAIT_TIME: float = 15.0 # in Sekunden angeben

var timer_to_complete: Timer # Timer bis Mission nach dem Start beendet werden muss, ansonsten fail
const DURATION_TIME: float = 0.50 # in Minuten angeben


func _ready():
	timer_to_start = Timer.new()
	timer_to_start.autostart = false
	timer_to_start.one_shot = true
	timer_to_start.timeout.connect(start_mission)
	add_child(timer_to_start)
	
	timer_to_complete = Timer.new()
	timer_to_complete.autostart = false
	timer_to_complete.one_shot = true
	timer_to_complete.timeout.connect(fail_mission)
	add_child(timer_to_complete)
	

func select_mission(mission: HuntingMission) -> void:
	if not multiplayer.is_server():
		return
	
	if current_mission and current_mission != mission:
		cancel_mission()
	
	current_mission = mission
	timer_to_start.start(WAIT_TIME)


func start_mission() -> void:
	if not multiplayer.is_server():
		return
	if not current_mission:
		return
		
	mission_started.emit(current_mission)
	timer_to_complete.start(DURATION_TIME * 60)


func cancel_mission() -> void:
	if not multiplayer.is_server():
		return
	if not current_mission:
		return
	
	timer_to_start.stop()
	print("Current Mission was canceled")
	mission_canceled.emit(current_mission)
	current_mission = null




func fail_mission():
	if not multiplayer.is_server():
		return
	if not current_mission:
		return
	
	timer_to_start.stop()
	print("Mission failed")
	mission_failed.emit(current_mission)
	current_mission = null


func complete_mission() -> void:
	if not multiplayer.is_server():
		return
	if current_mission:
		mission_completed.emit(current_mission)
		current_mission = null


func get_missions() -> Array[HuntingMission]:
	return hunting_catalog.missions
