extends Control
class_name PlayerHUD

@onready var health_bar = $HealthBar
@onready var stamina_bar = $StaminaBar


func setup_HUD(player: Player):
	player.health_component.health_changed.connect(_on_player_health_changed)
	
	health_bar.init_bar(player.get_current_health(), player.get_max_health())
	stamina_bar.init_bar(60,100)
	


func _on_player_health_changed(health_update: HealthUpdate):
	health_bar.value_changed(health_update.current_health, health_update.previous_health)
