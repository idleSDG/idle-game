class_name Character extends Node

@onready
var character = $"."
@onready
var particles = $GPUParticles2D
@onready
var bar = $Sprite2D/ProgressBar


var baseStats = CharacterStats.new()
var currentStats = baseStats #this should be replaced with cloning/duplicating (two seperate objects)

var skills = []
var skillToUse = -1


func _ready() -> void:
	var instance = Skill.new(200)
	skills.append(instance)
	
	pass




func PassTime(delta: float) -> void:
	for skill in skills:
		skill.Charge(delta)
	pass

func UpdateVisuals():
	bar.value = currentStats.health * 1.0 / baseStats.maxHealth
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
