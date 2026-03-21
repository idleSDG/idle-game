class_name MomentumConfig
extends Node

var min_multiplier: float = 0.5
var max_multiplier: float = 2.0
var target_value: float = 5000.0
var calculation_curve: Curve

func get_multiplier(current_value: float) -> float:
	var progress = clamp(current_value / target_value, 0.0, 1.0)
	var curve_factor = progress
	
	if calculation_curve:
		curve_factor = calculation_curve.sample(progress)
	
	return lerp(min_multiplier, max_multiplier, curve_factor)
