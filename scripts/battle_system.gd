extends Node

@onready
var canvas = $"Main Scene"
@onready
var characterSpawnPos = [$"Main Scene/Control", $"Main Scene/Control2", $"Main Scene/Control3",
 $"Main Scene/Control4", $"Main Scene/Control5", $"Main Scene/Control6"]


var character_scene = load("res://scenes/character.tscn")
var character_class = load("res://scripts/character.gd")

var characterList = []
var timer = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# TEMPORARY CODE
	var instance = character_scene.instantiate()
	characterList.append(instance)
	characterSpawnPos[0].add_child(instance)
	
	var instance2 = character_scene.instantiate()
	characterList.append(instance2)
	characterSpawnPos[1].add_child(instance2)
	
	pass # Replace with function body.




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if timer <= 0:
		update_visuals()
		if !try_skills():
			pass_time(delta)
		else:
			timer = 1.0
			print("--- waiting for 1.0 second :: skill executed")
	else:
		timer -= delta
	
	
	pass



func try_skills() -> bool:
	var i = 0
	var maxPos = -1
	var maxOvercharge = -1
	
	for c in characterList:
		var overcharge = c.CheckSkillCharge()
		if overcharge > maxOvercharge:
			maxOvercharge = overcharge
			maxPos = i
		i += 1
	
	if maxPos != -1:
		var target = characterList[1] if maxPos == 0 else characterList[0]
		characterList[maxPos].UseSkill(target)
		return true
	
	return false


func pass_time(delta: float) -> void:
	for c in characterList:
		c.PassTime(delta)
	pass

func update_visuals() :
	for c in characterList:
		c.UpdateVisuals()
	pass
