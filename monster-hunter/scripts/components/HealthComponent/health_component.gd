extends Node
class_name HealthComponent

signal health_changed(health_update: HealthUpdate)
signal died

@export var supressDamageFloat: bool = false 

var has_died: bool = false
var has_health_remaining: bool = !is_equal_approx(current_health, 0.0)
var current_health_percentage: float = current_health / max_health if max_health > 0 else 0.0


@onready var _max_health: float = max_health
@onready var _current_health: float = current_health

@export var max_health: float:
	set(new_value):
		_max_health = new_value
		if current_health > _max_health:
			current_health = _max_health
	get:
		return _max_health

@export var current_health: float:
	set(new_value):
		var previous_health = _current_health
		_current_health = clamp(new_value, 0, max_health)
		
		if not multiplayer.is_server():
			return
		
		rpc_update_health.rpc(get_current_health(), get_max_health())
		"""
		var health_update : HealthUpdate = HealthUpdate.new()
		health_update.previous_health = previous_health
		health_update.current_health = _current_health
		health_update.max_health = max_health
		health_update.health_percentage = current_health_percentage
		health_update.is_heal = previous_health <= _current_health
		
		emit_signal("health_changed",health_update)
		"""
		if !has_health_remaining && !has_died:
			has_died = true
			rpc_has_died.rpc()
	get():
		return _current_health


# var currentDamageFloat: TextFloat
func damage(damage: float, force_hide_damage: bool = false) -> void:
	current_health -= damage
	if !supressDamageFloat and !force_hide_damage:
		#currentDamageDamageFloat = FloatingTextManager.CreateOrUseDamageFloat(currentDamageFloat, GlobalPosition, damage)
		# TODO show damagenumber anzeigen
		pass

func heal(heal: float) -> void:
	damage(-heal,true)


func get_current_health() -> float:
	return _current_health

func get_max_health() -> float:
	return _max_health


func set_max_health(health: float):
	max_health = health
	rpc_update_health.rpc(get_current_health(), get_max_health())

func initialize_health():
	current_health = max_health


@rpc("call_local", "reliable")
func rpc_update_health(new_health: float, max_health: float):
	var previous_health = _current_health
	_current_health = new_health
	_max_health = max_health
	
	var health_update := HealthUpdate.new()
	health_update.previous_health = previous_health
	health_update.current_health = _current_health
	health_update.max_health = _max_health
	health_update.health_percentage = _current_health / max_health
	health_update.is_heal = previous_health < _current_health
	
	health_changed.emit(health_update)


@rpc("call_local", "reliable")
func rpc_has_died():
	has_died = true
	died.emit()
	
