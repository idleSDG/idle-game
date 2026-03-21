class_name MomentumConfig
extends Node

## The maximum value that impacts momentum. Any value above this will not increase the momentum further.
const MAX_VALUE_DOMAIN = 10000.0 

var min_multiplier: float = 0.5
var max_multiplier: float = 1.5
var calculation_curve: Curve

# TODO remove hard coded curve and make it configurable in inspector.
func _init():
	calculation_curve = Curve.new()
	calculation_curve.add_point(Vector2(0.0, 0.0))
	calculation_curve.add_point(Vector2(0.5, 0.5), 1.0, 0.1)
	calculation_curve.add_point(Vector2(1.0, 1.0), 3.0, 0.0)

func get_multiplier(current_value: float) -> float:
	var progress = clamp(current_value / MAX_VALUE_DOMAIN, 0.0, 1.0)
	var curve_factor = calculation_curve.sample(progress)
	return lerp(min_multiplier, max_multiplier, curve_factor)
