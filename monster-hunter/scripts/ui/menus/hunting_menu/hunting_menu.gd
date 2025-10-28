extends Control
class_name HuntingMenu

@onready var mission_container = $VBoxContainer/VScrollContainer/MissionContainer
@onready var start_button = $StartButton

var current_button: HuntingMissionButton

func _ready() -> void:
	load_missions()


func load_missions() -> void:
	for button in mission_container.get_children():
		button.queue_free()
	
	var missions: Array[HuntingMission] = HuntingManager.get_missions()
	for mission in missions:
		var button = HuntingMissionButton.new(mission)
		button.pressed.connect(_on_button_pressed.bind(button))
		mission_container.add_child(button)
	
	current_button = null
	start_button.disabled = true

func _on_button_pressed(button: Button):
	if current_button and current_button == button:
		start_mission()
		return
	current_button = button
	start_button.disabled = false
	


func start_mission() -> void:
	if not current_button:
		start_button.disabled = true
		return
	HuntingManager.select_mission(current_button.mission)
