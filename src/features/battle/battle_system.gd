extends Node

@onready var battle_ui: Control = $"Main Scene/Container/BattleUI"

@onready var canvas = $"Main Scene"
@onready var combatFinish = $"Main Scene/CombatFinishPopup"
@onready var characterSpawnPos = [
	$"Main Scene/Control",
	$"Main Scene/Control2",
	$"Main Scene/Control4",
	$"Main Scene/Control6",
	$"Main Scene/Control5",
	$"Main Scene/Control6",
]
@onready var timerLabel = $"Main Scene/SecondsLabel"

signal request_exit_signal
@onready var exit_button: Button = $"Main Scene/ExitBattle"
@onready var pause: CheckBox = $"Main Scene/HBoxContainer/Pause"
@onready var fast: CheckBox = $"Main Scene/HBoxContainer/Fast"

@onready var level: battle_level = BattleVariables.current_battle_level

var character_scene = load("res://scenes/character.tscn")
var character_class = load("res://scripts/character.gd")

var targetIndex = -1
var tempIndex = 1
var characterList: Array[Character] = []
var remainingEnemiesList = []
var enemyAmount: int = 4 # enemy amount = enemies on field + 1 (for the player)

var timer = 0.0
var gameSpeed = 1.0
var isPlaying = true

var _focus_lost_at: float = 0.0


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if not isPlaying:
			return
		_focus_lost_at = Time.get_unix_time_from_system()

	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		if not isPlaying:
			return
		var elapsed = Time.get_unix_time_from_system() - _focus_lost_at
		if elapsed > 0.5:
			simulate(elapsed)
			timerLabel.time = int(Time.get_unix_time_from_system() - BattleVariables.battleStart)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	characterList.resize(enemyAmount)
	if exit_button:
		exit_button.pressed.connect(_on_exit_battle_pressed)
	if BattleVariables.battleState == BattleVariables.BattleStates.AWAITING_EXIT:
		isPlaying = false
		combatFinish.visible = true
		combatFinish.text = "YOU WIN"
		exit_button.visible = true
		timerLabel.time = int(Time.get_unix_time_from_system() - BattleVariables.battleStart)
		return

	pause.set_pressed_no_signal(!BattleVariables.isPaused)
	fast.set_pressed_no_signal(!BattleVariables.isFast)

	# PLAYER INIT
	var instance = character_scene.instantiate()
	instance.SetStats(BattleVariables.GetPlayer())
	instance.level = PlayerProgress.level
	instance.charName = "Wizard"
	instance.isPlayer = true
	characterList[0] = instance
	characterSpawnPos[0].add_child(instance)
	characterList[0].hitbox.pressed.connect(select_enemy_unit.bind(0))
	characterList[0].index = 0
	SetPotions()

	# ENEMIES INIT
	for enemy in BattleVariables.current_battle_level.enemies:
		var instance2 := EnemyTypes.CreateEnemy(enemy, BattleVariables.current_battle_level.enemy_level)
		remainingEnemiesList.append(instance2)

	# Handles Loading and Simulating the battle after the game turns off OR sets it up for the future
	if BattleVariables.battleState == BattleVariables.BattleStates.IN_BATTLE:
		var now := Time.get_unix_time_from_system()
		BattleVariables.battleRNG = RandomNumberGenerator.new()
		BattleVariables.battleRNG.seed = BattleVariables.battleSeed

		simulate(BattleVariables.battleElapsed) #(now - BattleVariables.battleStart)
		timerLabel.time = int(now - BattleVariables.battleStart)
	else:
		BattleVariables.battleState = BattleVariables.BattleStates.IN_BATTLE
		BattleVariables.battleStart = Time.get_unix_time_from_system()
		BattleVariables.battleElapsed = 0.0
		BattleVariables.potionUsage = { }

		BattleVariables.battleSeed = RandomNumberGenerator.new().randf() * 100000
		BattleVariables.battleRNG = RandomNumberGenerator.new()
		BattleVariables.battleRNG.seed = BattleVariables.battleSeed

		# potion init must be here
		SetPotions()
		SaveManager.save_game()

	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
# Drives the primary game logic
func _process(delta: float) -> void:
	gameSpeed = 2.0 if BattleVariables.isFast else 1.0
	gameSpeed = 0.0 if BattleVariables.isPaused else gameSpeed

	delta = delta * gameSpeed
	BattleVariables.battleElapsed += delta

	if isPlaying: # if fight isnt finished
		update_visuals(delta)
		# timer - can be used for skill animations (if we want any), to stop time while anim is playing
		if timer <= 0:
			check_death()
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
	if characterList[0].baseStats.health <= 0:
		characterList[0].queue_free()
		characterList[0] = null
		finish_fight(false)

	for i in range(1, enemyAmount):
		if characterList[i] != null && characterList[i].baseStats.health <= 0:
			characterList[i].queue_free()
			characterList[i] = null


# spawns new enemies if there are any left in remainingEnemiesList
func check_enemies():
	for i in range(1, enemyAmount):
		if remainingEnemiesList.size() > 0:
			if characterList[i] == null:
				characterList[i] = remainingEnemiesList[0]
				characterSpawnPos[i].add_child(characterList[i])

				characterList[i].hitbox.pressed.connect(select_enemy_unit.bind(i))
				characterList[i].index = i

				#remainingEnemiesList[0]._ready()
				remainingEnemiesList.pop_front()
		else:
			break

	tempIndex = -1
	for j in range(1, enemyAmount):
		if characterList[j] != null:
			tempIndex = j
	if tempIndex == -1:
		finish_fight(true)
		return

	if targetIndex == -1 || characterList[targetIndex] == null:
		select_enemy_slot(tempIndex)

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
		# targeting logic should maybe be tweaked
		var target = characterList[targetIndex] if maxPos == 0 else characterList[0]
		if target != null && characterList[maxPos] != null:
			characterList[maxPos].UseSkill([target, characterList[1], characterList[2], characterList[3]])
			return true
		else:
			print("Number " + str(maxPos) + " says something's fucked")
			print(JSON.stringify(characterList))

	return false


# the main driver of gameplay - every character on the field charges their skills
func pass_time(delta: float, total: float = 0.0) -> void:
	for c in characterList:
		if c != null:
			c.PassTime(delta)

	battle_ui.PassTime(delta, total)

	pass


# used for bar updates and whatnot (though it'd be better to tie the bar to a variable)
func update_visuals(delta: float):
	for c in characterList:
		if c != null:
			c.UpdateVisuals(delta)
	battle_ui.UpdateStatDisplay()
	pass


# finishes the fight
func finish_fight(result: bool):
	BattleVariables.battleState = BattleVariables.BattleStates.AWAITING_EXIT
	isPlaying = false
	combatFinish.visible = true

	if result:
		BattleVariables.current_battle_level.beaten = true
		combatFinish.text = "YOU WIN"
		PlayerProgress.add_xp(120)
		characterList[0].ApplyExp()
	else:
		combatFinish.text = "YOU LOSE"

	SaveManager.save_game()
	exit_button.visible = true


# [length] is in seconds
# Simulates the game state in [length] seconds from battle start
func simulate(length: float):
	var step: float = 1.0 / 120.0

	while (length > 0):
		var delta = step
		length -= delta

		if isPlaying:
			#update_visuals(delta)
			check_enemies()
			if !try_skills():
				pass_time(delta, BattleVariables.battleElapsed - length)
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


func _on_exit_battle_pressed() -> void:
	BattleVariables.battleState = BattleVariables.BattleStates.IN_LEVEL_SELECT
	SaveManager.save_game()
	request_exit_signal.emit()


func select_enemy_unit(ind: int):
	select_enemy_slot(ind)

	battle_ui.StartPreview(characterList[ind])
	pass


func select_enemy_slot(ind: int):
	if (ind != 0):
		var i: int = 0
		for c in characterList:
			if c != null:
				c.select(c.index == ind)
				i += 1
		targetIndex = ind


func SetPotions():
	var pot1 = null
	var pot2 = null
	var pot3 = null
	for i in 3:
		print(i)
		for pot in PotionManager.potions:
			if pot.slot == i + 1:
				var instance = Potion.new(pot.id, i + 1)
				if i + 1 == 1:
					pot1 = instance
				if i + 1 == 2:
					pot2 = instance
				if i + 1 == 3:
					pot3 = instance
	battle_ui.SetPotions(pot1, pot2, pot3, characterList)


func _on_pause_toggled(toggled_on: bool) -> void:
	BattleVariables.isPaused = !toggled_on
	pass # Replace with function body.


func _on_fast_toggled(toggled_on: bool) -> void:
	BattleVariables.isFast = !toggled_on
	pass # Replace with function body.
