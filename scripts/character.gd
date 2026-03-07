class_name Character extends Node

var skillUiScene = load("res://scenes/skillUI.tscn")

@onready
var character = $"."
@onready
var particles = $GPUParticles2D
@onready
var healthBar = $VBoxContainer/Sprite2D/ProgressBar
@onready
var skillBars = $VBoxContainer/Sprite2D/HBox_Skills


var baseStats = CharacterStats.new()
var currentStats = baseStats #this should be replaced with cloning/duplicating (two seperate objects)

var skills = []
var skillToUse = -1


func _ready() -> void:
	var instance = Skill.new(200)
	skills.append(instance)
	
	for s in skills:
		#var bar = skillUiScene.instantiate()
		#s.skillBar = bar
		skillBars.add_child(s.skillBar)
	
	pass




func PassTime(delta: float) -> void:
	for skill in skills:
		skill.Charge(delta * currentStats.chargeRate)
	pass

func UpdateVisuals():
	healthBar.value = currentStats.health * 1.0 / baseStats.maxHealth
	pass


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

func UseSkill(target : Character) -> void:
	if skills[skillToUse].Use(self, target):
		particles.emitting = true
		
	skillToUse = -1
	pass
