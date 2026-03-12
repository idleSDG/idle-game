extends Node

@onready var canvas = $"Main Scene"
@onready var combatFinish = $"Main Scene/CombatFinishPopup"
@onready var characterSpawnPos = [
 $"Main Scene/Control",  $"Main Scene/Control2", $"Main Scene/Control3",
 $"Main Scene/Control4", $"Main Scene/Control5", $"Main Scene/Control6"]
@onready var timerLabel = $"Main Scene/SecondsLabel"

var character_scene = load("res://scenes/character.tscn")
var character_class = load("res://scripts/character.gd")

var targetIndex = 1
var characterList = [] # hard-coded to be 6 for now - 1 player and up to 5 enemies
var remainingEnemiesList = []

var timer = 0.0
var gameSpeed = 1.0
var isPlaying = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	characterList.resize(6)
	
	# ALL OF THE BELOW IS TEMPORARY CODE, THIS INFORMATION WOULD BE LOADED WHEN INSTANTIATING THE BATTLE
	var instance = character_scene.instantiate()
	instance.SetStats(GlobalVariables.GetPlayer())
	instance.charName = "Wizard"
	characterList[0] = instance
	characterSpawnPos[0].add_child(instance)
	
	for i in 10:
		var instance2 = character_scene.instantiate()
		remainingEnemiesList.append(instance2)
		instance2.charName = "Enemy" + str(i)
	# END OF TEMPORARY
	
	# Handles Loading and Simulating the battle after the game turns off OR sets it up for the future
	if GlobalVariables.inBattle:
		simulate(GlobalVariables.currentLogin - GlobalVariables.lastLogin)
		timerLabel.time = int(GlobalVariables.currentLogin - GlobalVariables.lastLogin)
	else:
		GlobalVariables.inBattle = true
		GlobalVariables.save_game()
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
# Drives the primary game logic
func _process(delta: float) -> void:
	delta = delta * gameSpeed  # easily add a speed up button that can increase game speed 2x/4x/etc.
	
	if isPlaying:		# if fight isnt finished
		update_visuals()
		# timer - can be used for skill animations (if we want any), to stop time while anim is playing
		if timer <= 0:
			check_enemies()
			if !try_skills():
				pass_time(delta)
			else:
				timer = 1.0
				print(":: skill executed")
				check_death()
		else:
			timer -= delta
	
	pass


# checks if the player and enemies are alive, handles them and finishes the Fight if conditions are met
func check_death():
	if characterList[0].currentStats.health <= 0:
		characterList[0].queue_free()
		characterList[0] = null
		finish_fight(false)
	
	for i in range(1, 6):
		if characterList[i] != null && characterList[i].currentStats.health <= 0:
			characterList[i].queue_free()
			characterList[i] = null
			
			targetIndex = -1
			for j in range(1, 6):
				if characterList[j] != null:
					targetIndex = j
			if targetIndex == -1:
				finish_fight(true)


# spawns new enemies if there are any left in remainingEnemiesList
func check_enemies():
	for i in range(1, 6):
		if remainingEnemiesList.size() > 0:
			if characterList[i] == null:
				characterList[i] = remainingEnemiesList[0]
				characterSpawnPos[i].add_child(characterList[i])
				remainingEnemiesList.pop_front()
		else: break
	
	pass


# checks if any character on the field can execute a skill, and if so, lets them use it
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
		# targeting logic should be tweaked
		var target = characterList[targetIndex] if maxPos == 0 else characterList[0]
		if target != null:
			characterList[maxPos].UseSkill(target)
		return true
	
	return false


# the main driver of gameplay - every character on the field charges their skills
func pass_time(delta: float) -> void:
	for c in characterList:
		if c != null:
			c.PassTime(delta)
	pass

# used for bar updates and whatnot (though it'd be better to tie the bar to a variable)
func update_visuals() :
	for c in characterList:
		if c != null:
			c.UpdateVisuals()
	pass

# finishes the fight
func finish_fight(result : bool):
	GlobalVariables.inBattle = false
	isPlaying = false
	combatFinish.visible = true
	
	GlobalVariables.save_game()
	
	if result:
		combatFinish.text = "YOU WIN"
	else:
		combatFinish.text = "YOU LOSE"
	pass


# [length] is in seconds
# Simulates the game state in [length] seconds from battle start
func simulate(length : float):
	var step : float = 1.0 / 120.0
	
	while (length > 0):
		var delta = step
		length -= delta
		
		if isPlaying:
			#update_visuals()
			check_enemies()
			if !try_skills():
				pass_time(delta)
			else:
				timer = 1.0
				check_death()
				
				if timer > length:
					return
				else:
					length -= timer
					timer = 0.0
		else:
			length = 0
	pass
