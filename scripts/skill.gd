extends Node

var charge = 0
var maxCharge = 100

func _init(max : float):
	maxCharge = max
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func Charge(delta: float) -> bool:
	charge += delta * 100
	
	return false

func GetOvercharge() -> float:
	if charge > maxCharge:
		return charge - maxCharge
	
	return -3

func Use() -> bool:
	charge -= maxCharge
	return true
