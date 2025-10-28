extends Button
class_name HuntingMissionButton

var mission: HuntingMission

func _init(_mission: HuntingMission):
	mission = _mission
	text = mission.name + "   " + str(mission.difficulty)
