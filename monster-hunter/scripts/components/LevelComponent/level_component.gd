extends Node
class_name LevelComponent

## -- Signals --
signal experience_changed(current_exp: float, needed_exp: float)
signal level_up(new_level: int)
signal level_changed(old_level: int, new_level: int)

## -- Exported variables --
@export var level: int = 1:
	set(value):
		if value != level:
			var old_level = level
			level = max(value, 1)
			emit_signal("level_changed", old_level, level)

@export var current_exp: float = 0.0
@export var base_exp_to_next_level: float = 100.0
@export var exp_growth_factor: float = 1.25
@export var max_level: int = 99
@export var auto_reset_exp_on_levelup: bool = true

## -- Optional callback für eigene Berechnung --
var custom_exp_formula: Callable = Callable()

## -- Public API --

func add_experience(amount: float) -> void:
	if amount <= 0:
		return
	
	current_exp += amount
	emit_signal("experience_changed", current_exp, get_exp_to_next_level())

	while current_exp >= get_exp_to_next_level() and level < max_level:
		current_exp -= get_exp_to_next_level() if auto_reset_exp_on_levelup else 0
		_level_up()

func remove_experience(amount: float) -> void:
	if amount <= 0:
		return
	
	current_exp = max(0, current_exp - amount)
	emit_signal("experience_changed", current_exp, get_exp_to_next_level())

func get_exp_to_next_level() -> float:
	if custom_exp_formula.is_valid():
		return custom_exp_formula.call(level)
	return base_exp_to_next_level * pow(exp_growth_factor, level - 1)

func get_level_progress() -> float:
	return clamp(current_exp / get_exp_to_next_level(), 0.0, 1.0)

func get_level() -> int:
	return level

func get_current_experience() -> float:
	return current_exp

func reset_level() -> void:
	level = 1
	current_exp = 0
	emit_signal("experience_changed", current_exp, get_exp_to_next_level())

func set_custom_formula(callable: Callable) -> void:
	custom_exp_formula = callable

## -- Private --
func _level_up() -> void:
	if level >= max_level:
		current_exp = 0
		return
	level += 1
	emit_signal("level_up", level)
	emit_signal("experience_changed", current_exp, get_exp_to_next_level())
