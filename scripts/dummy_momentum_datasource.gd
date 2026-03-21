class_name DummyMomentumDataSource
extends Node

enum Pattern { SINE_WAVE, WORKOUT_BURSTS, STEADY_CLIMB }

@export var active_pattern: Pattern = Pattern.STEADY_CLIMB
@export var base_value: float = 2500.0
@export var variation: float = 1500.0
@export var history_interval: float = 60

func _get_mock_value(timestamp: float) -> float:
	match active_pattern:
		Pattern.SINE_WAVE:
			var period = 3600.0 
			var wave = sin((timestamp / period) * TAU) 
			return base_value + (wave * variation)
			
		Pattern.WORKOUT_BURSTS:
			var hour_pos = fmod(timestamp, 3600.0)
			return base_value + (variation if hour_pos < 600.0 else -base_value)
			
		Pattern.STEADY_CLIMB:
			var day_pos = fmod(timestamp, 86400.0) / 86400.0
			return base_value + (variation * (pow(2.0, day_pos * 4.0) - 1.0) / 15.0)
			
	return base_value

func get_history(p_start_time: float, p_end_time: float) -> Array:
	var history := []
	
	var current = p_start_time
	while current <= p_end_time:
		history.append({
			"time": current,
			"val": _get_mock_value(current)
		})
		current += history_interval
		
	return history

func get_latest_value() -> Dictionary:
	var now_unix = Time.get_unix_time_from_system()
	return {
			"time": now_unix,
			"val": _get_mock_value(now_unix)
		}
