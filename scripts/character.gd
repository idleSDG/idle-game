class_name Character extends Node

var damagePopup = load("res://scenes/damagePopup.tscn")
var skillUiScene = load("res://scenes/skillUI.tscn")
var charName = "Character"

@onready var character = $"."
@onready var particles = $GPUParticles2D
@onready var healthBar = $VBoxContainer/Sprite2D/ProgressBar
@onready var skillBars = $VBoxContainer/Sprite2D/HBox_Skills

@onready var baseSprite = $VBoxContainer/BaseSprite
@onready var wizardSprites = $VBoxContainer/BaseSprite/WIZARDSPECIFIC


var isPlayer : bool = false
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
	
	if isPlayer:
		baseSprite.texture = load("res://assets/wizard_defaults/wizardBase.png")
		wizardSprites.visible = true;
	else:
		baseSprite.texture = load("res://assets/enemies/skeleton.png") if RandomNumberGenerator.new().randf() > 0.5 else load("res://assets/enemies/wolf.png")
	
	pass

func SetStats(stats : CharacterStats) :
	# TEMPORARY CODE
	var instance = Skill.new(1.3, 300.0, CharacterStats.Element.Fire)
	skills.append(instance)
	# END OF TEMPORARY CODE
	
	baseStats = stats
	currentStats = baseStats
	
	isPlayer = true
	
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
	character.get_parent().get_parent().add_child(popup)
	popup.SetUp(character.get_parent().position, dmg, itCrit)
	
	pass
