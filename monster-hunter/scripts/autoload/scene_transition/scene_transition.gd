extends CanvasLayer

@onready var animation_player = $AnimationPlayer # Für zusätzliche Effekte
@onready var color_rect = $ColorRect

var is_transitioning = false

func _ready():
	# ColorRect setup
	color_rect.color = Color.BLACK
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Start transparent
	color_rect.modulate.a = 0.0
	
	# Layer immer ganz oben
	layer = 100

# Fade to black, dann Scene wechseln, dann fade from black
func change_scene(target_scene: String, duration: float = 0.5):
	if is_transitioning:
		return
	
	is_transitioning = true
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Fade out
	await fade_out(duration)
	
	# Scene wechseln
	get_tree().change_scene_to_file(target_scene)
	
	# Kurz warten damit Scene geladen ist
	await get_tree().process_frame
	
	# Fade in
	await fade_in(duration)
	
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false


# Nur fade out (ohne Scene-Wechsel)
func fade_out(duration: float = 0.5) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(color_rect, "modulate:a", 1.0, duration)
	await tween.finished

# Nur fade in (ohne Scene-Wechsel)
func fade_in(duration: float = 0.5) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(color_rect, "modulate:a", 0.0, duration)
	await tween.finished

# Instant fade (z.B. beim Spielstart)
func fade_in_instant():
	color_rect.modulate.a = 1.0
	await fade_in(0.8)
