extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if try_skills():
		pass_time()
	pass



func try_skills() -> bool:
	return false


func pass_time() -> void:
	pass
