extends Resource
class_name StatusEffect

enum Effects {
	Slow
}

var effect: Effects
var duration: float
var elapsed: float = 0.0
var tick_interval: float = 0.0
var tick_timer: float = 0.0
var on_apply: Callable = Callable()
var on_tick: Callable = Callable()
var on_expire: Callable = Callable()

func _init(_effect: Effects, _duration: float, _tick_interval: float = 0.0,
		   _on_apply: Callable = Callable(), _on_tick: Callable = Callable(), _on_expire: Callable = Callable()):
	effect = _effect
	duration = _duration
	tick_interval = _tick_interval
	on_apply = _on_apply
	on_tick = _on_tick
	on_expire = _on_expire
