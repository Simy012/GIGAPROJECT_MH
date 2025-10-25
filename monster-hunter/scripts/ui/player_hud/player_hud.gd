extends Control
class_name PlayerHUD

@onready var health_bar = $HealthBar
@onready var stamina_bar = $StaminaBar


func setup_HUD(player: Player):
	player.health_component.health_changed.connect(_on_player_health_changed)
	player.movement_component.stamina_changed.connect(_on_player_stamina_changed)
	
	health_bar.init_bar(player.get_current_health(), player.get_max_health())
	stamina_bar.init_bar(player.get_current_stamina(), player.get_max_stamina())
	


func _on_player_health_changed(health_update: HealthUpdate):
	health_bar.change_value(health_update.current_health)


func _on_player_stamina_changed(current: float, max: float):
	if max != stamina_bar.max_value:
		stamina_bar.max_value_updated(max)
	stamina_bar.change_value(current)
