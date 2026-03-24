class_name Character extends Node

var damagePopup = load("res://scenes/damagePopup.tscn")
var skillUiScene = load("res://scenes/skillUI.tscn")
var charName = "Character"

@onready var character = $"."
@onready var particles = $GPUParticles2D
@onready var healthBar = $VBoxContainer/Sprite2D/ProgressBar
@onready var skillBars = $VBoxContainer/Sprite2D/HBox_Skills


var baseStats = CharacterStats.new()
var currentStats = baseStats # this should be replaced with cloning/duplicating baseStats

var skills = []
var skillToUse = -1


func _ready() -> void:
	# TEMPORARY CODE
	var instance = Skill.new(1.0, 200.0)
	skills.append(instance)
	# END OF TEMPORARY CODE
	
	for s in skills:
		skillBars.add_child(s.skillBar)
	
	pass

func SetStats(stats : CharacterStats) :
	# TEMPORARY CODE
	var instance = Skill.new(1.3, 300.0)
	skills.append(instance)
	# END OF TEMPORARY CODE
	
	baseStats = stats
	currentStats = baseStats
	
	pass


# Charge every skill
func PassTime(delta: float) -> void:
	for skill in skills:
		skill.Charge(delta * currentStats.chargeRate)
	pass

# Update health bar (should be replaced by tying it to a variable)
func UpdateVisuals():
	healthBar.value = currentStats.health * 1.0 / baseStats.maxHealth
	pass


# finds the highest overcharge of a skill and returns it (overcharge = charge amount above maxCharge)
func CheckSkillCharge() -> float:
	var val = -2
	var i = 0
	
	for skill in skills:
		var skillOvercharge = skill.GetOvercharge()
		if skillOvercharge > val:
			val = skillOvercharge
			skillToUse = i
		i += 1
	
	return val

# Use skill against target
func UseSkill(target : Character) -> void:
	if skills[skillToUse].Use(self, target):
		particles.emitting = true
		
	skillToUse = -1
	pass

# Take damage and create a text popup
func TakeDamage(dmg : int, itCrit : bool):
	currentStats.TakeDamage(dmg)
	
	var popup = damagePopup.instantiate()
	var popup_root = get_tree().get_first_node_in_group("battle_popup_root")
	if popup_root:
		popup_root.add_child(popup)
	popup.SetUp(character.get_parent().position, dmg, itCrit)
	
	pass
