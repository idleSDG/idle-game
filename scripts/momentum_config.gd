class_name MomentumConfig
extends Node

## The maximum value that impacts momentum. Any value above this will not increase the momentum further.
const DEFAULT_MAX_VALUE_DOMAIN = 12000.0

var min_multiplier: float = 0.5
var max_multiplier: float = 1.5
var value_for_100_percent: float
var max_value_domain: float

# TODO remove hard coded curve and make it configurable in inspector.
func _init(p_value_for_100_percent: float = 6000.0, p_max_value_domain: float = DEFAULT_MAX_VALUE_DOMAIN):
	value_for_100_percent = maxf(p_value_for_100_percent, 1.0)
	max_value_domain = maxf(p_max_value_domain, value_for_100_percent + 1.0)

func get_multiplier(current_value: float) -> float:
	var curve_factor: float
	if current_value <= value_for_100_percent:
		var lower_t: float = clampf(current_value / value_for_100_percent, 0.0, 1.0)
		curve_factor = lerp(0.0, 0.5, lower_t)
	else:
		var upper_t: float = clampf((current_value - value_for_100_percent) / (max_value_domain - value_for_100_percent), 0.0, 1.0)
		curve_factor = lerp(0.5, 1.0, upper_t)
	return lerp(min_multiplier, max_multiplier, curve_factor)
