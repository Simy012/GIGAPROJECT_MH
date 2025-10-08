extends Node

signal multiplayer_mode_enabled_changed(enabled: bool)
var multiplayer_mode_enabled: bool = false:
	set(value):
		multiplayer_mode_enabled = value
		multiplayer_mode_enabled_changed.emit(multiplayer_mode_enabled)

var host_mode_enabled = false
var respawn_point = Vector2(30, 20)
