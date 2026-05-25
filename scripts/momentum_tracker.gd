class_name MomentumTracker
extends Node

var momentumConfig: MomentumConfig
var datasource

func _init(p_momentumConfig: MomentumConfig, p_datasource):
	self.momentumConfig = p_momentumConfig
	self.datasource = p_datasource

## Calculates the effective multiplier over a specific window.
func get_time_weighted_multiplier(start_t: float, end_t: float) -> float:
	var history: Array = datasource.get_history(start_t, end_t)
	
	if history.size() < 2:
		return get_momentum_at_timestamp(end_t) 

	var total_area: float = 0.0
	var total_duration: float = 0.0
	
	for i in range(history.size() - 1):
		var p1 = history[i]
		var p2 = history[i+1]
		
		if p2.time <= start_t or p1.time >= end_t:
			continue
			
		var segment_start = max(p1.time, start_t)
		var segment_end = min(p2.time, end_t)
		var duration = segment_end - segment_start
		
		if duration <= 0: continue
		
		var m1 = momentumConfig.get_multiplier(p1.val)
		var m2 = momentumConfig.get_multiplier(p2.val)
		
		total_area += ((m1 + m2) / 2.0) * duration
		total_duration += duration

	return total_area / total_duration if total_duration > 0 else momentumConfig.get_multiplier(0.0)

## TODO: is this correct? why is param unused
func get_momentum_at_timestamp(_p_timestamp: float) -> float:
	return momentumConfig.get_multiplier(datasource.get_latest_value().val)
