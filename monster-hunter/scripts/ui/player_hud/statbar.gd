extends ProgressBar
class_name Statbar 

@onready var timer = $Timer
@onready var used_bar: ProgressBar = $UsedBar

func _ready():
	pass


func value_changed(new_value, old_value):
	value = min(max_value, new_value)
	
	if value < 0:
		value = 0
	
	if value < old_value:
		timer.start()
	else:
		used_bar.value = value 


func max_value_updated(new_value):
	max_value = new_value
	used_bar.max_value = new_value


func init_bar(_value,_max_value):
	max_value = _max_value
	value = _value
	used_bar.max_value = _max_value
	used_bar.value = value


func _on_timer_timeout():
	used_bar.value = value
