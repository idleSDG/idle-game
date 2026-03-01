extends Node

var character_scene = load("res://scenes/character.tscn")
var character_class = load("res://scripts/character_temporary.gd")

var characterList = []
var timer = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var instance = character_scene.instantiate()
	characterList.append(instance)
	add_child(instance)
	instance.transform = Transform2D(0, Vector2(180, 1000))
	
	var instance2 = character_scene.instantiate()
	characterList.append(instance2)
	add_child(instance2)
	instance2.transform = Transform2D(0, Vector2(900, 1000))
	
	pass # Replace with function body.




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if timer <= 0:
		if !try_skills():
			pass_time(delta)
		else:
			timer = 1.0
			print("--- waiting")
	else:
		timer -= delta
	
	
	pass



func try_skills() -> bool:
	var i = 0
	var maxPos = -1
	var maxOvercharge = -1
	
	for c in characterList:
		var overcharge = c.CheckSkillCharge()
		print("char overcharge: %f" % overcharge)
		if overcharge > maxOvercharge:
			maxOvercharge = overcharge
			maxPos = i
		i += 1
	
	if maxPos != -1:
		characterList[maxPos].UseSkill()
		return true
	
	return false


func pass_time(delta: float) -> void:
	for c in characterList:
		c.PassTime(delta)
	pass
