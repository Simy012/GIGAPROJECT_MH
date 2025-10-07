extends Control

# Video Tabs
@onready var v_box_container = $VBoxContainer
@onready var fullscreen_check = $VBoxContainer/TabContainer/Video/VideoSetings/Fullscreen/FullscreenCheck
@onready var vsync_check = $VBoxContainer/TabContainer/Video/VideoSetings/Vsync/VsyncCheck
@onready var resolution_button = $VBoxContainer/TabContainer/Video/VideoSetings/ResolutionOption/ResolutionButton
@onready var quality_button = $VBoxContainer/TabContainer/Video/VideoSetings/QualtityOption/QualityButton
@onready var brightness_slider = $VBoxContainer/TabContainer/Video/VideoSetings/Brightness/BrightnessSlider


# Audio Tabs
@onready var master_slider = $VBoxContainer/TabContainer/Audio/AudioSettings/MasterSlider/MasterSlider
@onready var music_slider = $VBoxContainer/TabContainer/Audio/AudioSettings/MusicSlider/MusicSlider
@onready var sfx_slider = $VBoxContainer/TabContainer/Audio/AudioSettings/SFXSlider/SFXSlider


# Gameplay Tabs
@onready var mouse_sensitivity_slider = $VBoxContainer/TabContainer/Gameplay/GameplaySettings/MouseSensitivity/MouseSensitivitySlider
@onready var camera_shake_check = $VBoxContainer/TabContainer/Gameplay/GameplaySettings/CameraShakeCheck/CameraShakeCheck

# Buttons
@onready var apply_button = $HBoxContainer/ApplyButton
@onready var reset_button = $HBoxContainer/ResetButton
@onready var back_button = $HBoxContainer/BackButton


func _ready():
	# Load current settings
	load_current_settings()
	
	# Resolution Options
	resolution_button.add_item("1920x1080")
	resolution_button.add_item("1600x900")
	resolution_button.add_item("1366x768")
	resolution_button.add_item("1280x720")
	
	# Quality Options
	quality_button.add_item("Niedrig")
	quality_button.add_item("Mittel")
	quality_button.add_item("Hoch")

func load_current_settings():
	# Video
	fullscreen_check.button_pressed = SettingsManager.fullscreen
	vsync_check.button_pressed = SettingsManager.vsync
	brightness_slider.value = SettingsManager.brightness
	quality_button.selected = SettingsManager.quality_preset
	
	# Resolution
	match SettingsManager.resolution:
		Vector2i(1920, 1080): resolution_button.selected = 0
		Vector2i(1600, 900): resolution_button.selected = 1
		Vector2i(1366, 768): resolution_button.selected = 2
		Vector2i(1280, 720): resolution_button.selected = 3
	
	# Audio
	master_slider.value = SettingsManager.master_volume
	music_slider.value = SettingsManager.music_volume
	sfx_slider.value = SettingsManager.sfx_volume
	
	# Gameplay
	mouse_sensitivity_slider.value = SettingsManager.mouse_sensitivity
	camera_shake_check.button_pressed = SettingsManager.camera_shake

func _on_apply_pressed():
	# Video
	SettingsManager.fullscreen = fullscreen_check.button_pressed
	SettingsManager.vsync = vsync_check.button_pressed
	SettingsManager.brightness = brightness_slider.value
	SettingsManager.quality_preset = quality_button.selected
	
	# Resolution
	match resolution_button.selected:
		0: SettingsManager.resolution = Vector2i(1920, 1080)
		1: SettingsManager.resolution = Vector2i(1600, 900)
		2: SettingsManager.resolution = Vector2i(1366, 768)
		3: SettingsManager.resolution = Vector2i(1280, 720)
	
	# Audio
	SettingsManager.master_volume = master_slider.value
	SettingsManager.music_volume = music_slider.value
	SettingsManager.sfx_volume = sfx_slider.value
	
	# Gameplay
	SettingsManager.mouse_sensitivity = mouse_sensitivity_slider.value
	SettingsManager.camera_shake = camera_shake_check.button_pressed
	
	# Save and apply
	SettingsManager.save_settings()
	SettingsManager.apply_settings()
	
	print("Einstellungen angewendet!")

func _on_reset_pressed():
	SettingsManager.reset_to_defaults()
	load_current_settings()
	print("Einstellungen zurückgesetzt!")

func _on_back_pressed():
	SceneTransition.change_scene(GlobalData.MAIN_MENU_SCENE)
