extends Node

@onready
var canvas = $"Main Scene"
@onready
var characterSpawnPos = [$"Main Scene/Control", $"Main Scene/Control2", $"Main Scene/Control3",
 $"Main Scene/Control4", $"Main Scene/Control5", $"Main Scene/Control6"]


var character_scene = load("res://scenes/character.tscn")
var character_class = load("res://scripts/character.gd")

#var playerCharacter
var targetIndex = 1
var characterList = []
var remainingEnemiesList = []
var timer = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	characterList.resize(6)
	
	# TEMPORARY CODE
	var instance = character_scene.instantiate()
	instance.SetStats(GlobalVariables.GetPlayer())
	characterList[0] = instance
	characterSpawnPos[0].add_child(instance)
	
	for i in 10:
		var instance2 = character_scene.instantiate()
		remainingEnemiesList.append(instance2)
		#characterList.append(instance2)
		#characterSpawnPos[1].add_child(instance2)
	
	pass # Replace with function body.




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_visuals()
	check_death()
	if timer <= 0:
		check_enemies()
		if !try_skills():
			pass_time(delta)
		else:
			timer = 1.0
			print("--- waiting for 1.0 second :: skill executed")
	else:
		timer -= delta
	
	
	pass


func check_death():
	for i in range(0, 6):
		if characterList[i] != null && characterList[i].currentStats.health <= 0:
			characterList[i].queue_free()
			characterList[i] = null
			print("man im dead")
			
			for j in range(1, 6):
				if characterList[j] != null:
					targetIndex = j

func check_enemies():
	for i in range(1, 6):
		if remainingEnemiesList.size() > 0:
			if characterList[i] == null:
				characterList[i] = remainingEnemiesList[0]
				characterSpawnPos[i].add_child(characterList[i])
				remainingEnemiesList.pop_front()
		else: break
	
	pass


func try_skills() -> bool:
	var i = 0
	var maxPos = -1
	var maxOvercharge = -1
	
	for c in characterList:
		if c != null:
			var overcharge = c.CheckSkillCharge()
			if overcharge > maxOvercharge:
				maxOvercharge = overcharge
				maxPos = i
			i += 1
	
	if maxPos != -1:
		var target = characterList[targetIndex] if maxPos == 0 else characterList[0]
		characterList[maxPos].UseSkill(target)
		return true
	
	return false


func pass_time(delta: float) -> void:
	for c in characterList:
		if c != null:
			c.PassTime(delta)
	pass

func update_visuals() :
	for c in characterList:
		if c != null:
			c.UpdateVisuals()
	pass
