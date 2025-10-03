extends Node
class_name StatusEffectComponent

## Signal, wenn ein Effekt hinzugefügt oder entfernt wird
signal effect_applied(effect_name: String)
signal effect_removed(effect_name: String)

## Interne Datenstruktur für aktive Effekte
var active_effects: Dictionary = {}




func _process(delta: float) -> void:
	var to_remove := []

	for effect_name in active_effects.keys():
		var effect: StatusEffect = active_effects[effect_name]
		effect.elapsed += delta

		# Tick-Logik
		if effect.tick_interval > 0.0:
			effect.tick_timer += delta
			if effect.tick_timer >= effect.tick_interval:
				effect.tick_timer = 0.0
				if effect.on_tick:
					effect.on_tick.call()

		# Ablauf prüfen
		if effect.elapsed >= effect.duration:
			if effect.on_expire:
				effect.on_expire.call()
			to_remove.append(effect_name)

	# Entferne abgelaufene Effekte
	for name in to_remove:
		active_effects.erase(name)
		emit_signal("effect_removed", name)

func apply_effect(effect: StatusEffect) -> void:
	if effect.name in active_effects:
		# Optional: Effekt erneuern oder ignorieren
		active_effects[effect.name].elapsed = 0.0
	else:
		active_effects[effect.name] = effect
		if effect.on_apply:
			effect.on_apply.call()
		emit_signal("effect_applied", effect.name)

func remove_effect(effect_name: String) -> void:
	if effect_name in active_effects:
		var effect = active_effects[effect_name]
		if effect.on_expire:
			effect.on_expire.call()
		active_effects.erase(effect_name)
		emit_signal("effect_removed", effect_name)

func has_effect(effect_name: String) -> bool:
	return effect_name in active_effects
