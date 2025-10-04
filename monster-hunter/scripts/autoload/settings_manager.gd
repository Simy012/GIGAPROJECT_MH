extends Node

# Einstellungen Pfad
const SETTINGS_FILE = "user://settings.cfg"

# Video Einstellungen
var fullscreen: bool = false
var vsync: bool = true
var resolution: Vector2i = Vector2i(1920, 1080)
var brightness: float = 1.0
var quality_preset: int = 1 # 0=Low, 1=Medium, 2=High

# Audio Einstellungen
var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 0.9

# Gameplay Einstellungen
var mouse_sensitivity: float = 0.5
var fov: float = 75.0
var camera_shake: bool = true

signal settings_changed

func _ready():
	load_settings()
	apply_settings()

func load_settings():
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_FILE)
	
	if err != OK:
		print("Keine Einstellungen gefunden, verwende Standard-Einstellungen")
		save_settings()
		return
	
	# Video
	fullscreen = config.get_value("video", "fullscreen", false)
	vsync = config.get_value("video", "vsync", true)
	resolution = config.get_value("video", "resolution", Vector2i(1920, 1080))
	brightness = config.get_value("video", "brightness", 1.0)
	quality_preset = config.get_value("video", "quality_preset", 1)
	
	# Audio
	master_volume = config.get_value("audio", "master_volume", 1.0)
	music_volume = config.get_value("audio", "music_volume", 0.8)
	sfx_volume = config.get_value("audio", "sfx_volume", 0.9)
	
	# Gameplay
	mouse_sensitivity = config.get_value("gameplay", "mouse_sensitivity", 0.5)
	fov = config.get_value("gameplay", "fov", 75.0)
	camera_shake = config.get_value("gameplay", "camera_shake", true)

func save_settings():
	var config = ConfigFile.new()
	
	# Video
	config.set_value("video", "fullscreen", fullscreen)
	config.set_value("video", "vsync", vsync)
	config.set_value("video", "resolution", resolution)
	config.set_value("video", "brightness", brightness)
	config.set_value("video", "quality_preset", quality_preset)
	
	# Audio
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	
	# Gameplay
	config.set_value("gameplay", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("gameplay", "fov", fov)
	config.set_value("gameplay", "camera_shake", camera_shake)
	
	config.save(SETTINGS_FILE)
	print("Einstellungen gespeichert")

func apply_settings():
	# Fullscreen
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(resolution)
	
	# VSync
	if vsync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	# Audio Busse
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx_volume))
	
	# Quality Preset anwenden
	apply_quality_preset()
	
	settings_changed.emit()

func apply_quality_preset():
	match quality_preset:
		0: # Low
			RenderingServer.set_default_clear_color(Color(0.05, 0.05, 0.05))
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", 0)
			ProjectSettings.set_setting("rendering/shadows/positional_shadow/soft_shadow_filter_quality", 0)
		1: # Medium
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", 2)
			ProjectSettings.set_setting("rendering/shadows/positional_shadow/soft_shadow_filter_quality", 2)
		2: # High
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", 4)
			ProjectSettings.set_setting("rendering/shadows/positional_shadow/soft_shadow_filter_quality", 4)

func reset_to_defaults():
	fullscreen = false
	vsync = true
	resolution = Vector2i(1920, 1080)
	brightness = 1.0
	quality_preset = 1
	master_volume = 1.0
	music_volume = 0.8
	sfx_volume = 0.9
	mouse_sensitivity = 0.5
	fov = 75.0
	camera_shake = true
	
	save_settings()
	apply_settings()
