class_name Healthbar extends ProgressBar

@onready var timer = $Timer
@onready var damage_bar = $DamageBar



func health_changed(new_value, old_value):
	value = min(max_value, new_value)
	
	if value <= 0:
		queue_free()
	
	if value < old_value:
		timer.start()
	else:
		damage_bar.value = value 
	visible = true

func max_health_updated(new_value):
	max_value = new_value
	damage_bar.max_value = new_value


func init_health(_health,max_health):
	max_value = max_health
	value = _health
	damage_bar.max_value = value
	damage_bar.value = value


func _on_timer_timeout():
	damage_bar.value = value
