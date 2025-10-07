extends Node
class_name StatusEffectComponent

# Referenz zum Player
var player: CharacterBody3D

# Status Effect State
var stun_timer: float = 0.0
var slow_timer: float = 0.0
var slow_multiplier: float = 1.0

# Signals
signal stunned(duration: float)
signal stun_ended
signal slowed(duration: float, amount: float)
signal slow_ended

func _process(delta):
	# Timers runterzählen
	if stun_timer > 0:
		stun_timer -= delta
		if stun_timer <= 0:
			end_stun()
	
	if slow_timer > 0:
		slow_timer -= delta
		if slow_timer <= 0:
			end_slow()

func apply_stun(duration: float):
	"""
	Betäubung durch Monster-Schrei z.B.
	"""
	print("Player stunned for %s seconds!" % duration)
	stun_timer = duration
	stunned.emit(duration)
	
	# Visual Feedback (optional)
	show_stun_effect()

func end_stun():
	print("Stun ended!")
	stun_ended.emit()
	hide_stun_effect()

func apply_slow(duration: float, amount: float):
	"""
	Verlangsamung durch Monster-Angriff
	amount: 0.0 bis 1.0 (0.5 = 50% langsamer)
	"""
	print("Player slowed for %s seconds (amount: %s)!" % [duration, amount])
	slow_timer = duration
	slow_multiplier = 1.0 - amount
	slowed.emit(duration, amount)
	
	# Visual Feedback (optional)
	show_slow_effect()

func end_slow():
	print("Slow ended!")
	slow_multiplier = 1.0
	slow_ended.emit()
	hide_slow_effect()

func is_stunned() -> bool:
	return stun_timer > 0

func is_slowed() -> bool:
	return slow_timer > 0

func get_slow_multiplier() -> float:
	return slow_multiplier

func clear_all_effects():
	"""
	Alle Status-Effekte entfernen
	"""
	stun_timer = 0
	slow_timer = 0
	slow_multiplier = 1.0
	end_stun()
	end_slow()

# Visual Feedback Methoden (optional implementieren)
func show_stun_effect():
	# TODO: Particle Effect, Screen shake, etc.
	pass

func hide_stun_effect():
	# TODO: Effekte ausblenden
	pass

func show_slow_effect():
	# TODO: Blauer Effekt, Trail, etc.
	pass

func hide_slow_effect():
	# TODO: Effekte ausblenden
	pass
