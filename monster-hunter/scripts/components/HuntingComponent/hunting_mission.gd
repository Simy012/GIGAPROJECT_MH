extends Resource
class_name HuntingMission

@export var name: StringName
@export var description: String
@export var monster_scene: PackedScene
@export var hunting_ground: GlobalData.LEVEL
@export var difficulty: int = 1
@export var reward: int = 1000
@export var icon: Texture2D

# Hier vielleicht auch noch Gruppen für gruppierung einfügen, z.b. Wald/ Mountain, Cave, etc.
# Die Gruppen könnten auch noch hunting grorund getrennt sein
