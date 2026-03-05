extends Node

# Signals
signal xp_changed(current_xp: int, xp_required: int)
signal leveled_up(new_level: int)

# Configuration
const BASE_XP: int = 100
const EXPONENT: float = 1.5

# State
var level: int = 1
var current_xp: int = 0

## Call this from combat, crafting, or any active action
func add_xp(amount: int) -> void:
	current_xp += amount
	_check_level_up()
	xp_changed.emit(current_xp, xp_required_for_next_level())

## XP needed to advance FROM current level TO next
func xp_required_for_next_level() -> int:
	return _xp_for_level(level)

## How far through the current level the player is (0.0 → 1.0), useful for XP bar
func xp_progress_ratio() -> float:
	return clampf(float(current_xp) / float(xp_required_for_next_level()), 0.0, 1.0)

func _xp_for_level(lvl: int) -> int:
	return int(BASE_XP * pow(lvl, EXPONENT))

func _check_level_up() -> void:
	while current_xp >= xp_required_for_next_level():
		current_xp -= xp_required_for_next_level()
		level += 1
		leveled_up.emit(level)
		print("[PlayerProgress] Level up! Now level %d (next level needs %d XP)" 
			% [level, xp_required_for_next_level()])
