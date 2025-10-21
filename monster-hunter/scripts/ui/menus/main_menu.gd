extends Control


@onready var play_button = $Buttoncontainer/PlayButton
@onready var settings_button = $Buttoncontainer/SettingsButton
@onready var quit_button = $Buttoncontainer/QuitButton


@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready():
	# Buttons verbinden
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
		
	# Cursor sichtbar machen
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Fade-in beim Betreten
	SceneTransition.fade_in_instant()
	
	# Menu Animation starten
	if animation_player:
		animation_player.play("menu_intro")


func _on_play_pressed():
	if SceneTransition.is_transitioning:
		return
	play_button_sound()
	disable_buttons()
	
	SceneTransition.change_scene(GlobalData.CHARACTER_SELECTION_SCENE, 0.4)


func _on_settings_pressed():
	if SceneTransition.is_transitioning:
		return
	play_button_sound()
	disable_buttons()
	
	SceneTransition.change_scene(GlobalData.SETTINGS_MENU_SCENE, 0.4)


func _on_quit_pressed():
	if SceneTransition.is_transitioning:
		return
	play_button_sound()
	GameManager.quit_game()



func play_button_sound():
	# Hier Audio abspielen wenn vorhanden
	if has_node("ButtonClickSound"):
		$ButtonClickSound.play()
		# Kurz warten damit Sound abgespielt wird
		await get_tree().create_timer(0.1).timeout


func disable_buttons():
	play_button.disabled = true
	settings_button.disabled = true
	quit_button.disabled = true
