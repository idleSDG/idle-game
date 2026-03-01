extends Node

@onready
var character = $"."
@onready
var particles = $GPUParticles2D


var skill_class = load("res://scripts/skill.gd")
var skills = []
var skillToUse = -1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var instance = skill_class.new(200)
	skills.append(instance)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func PassTime(delta: float) -> void:
	for skill in skills:
		skill.Charge(delta)
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

func UseSkill() -> void:
	if skills[skillToUse].Use():
		particles.emitting = true
		
	skillToUse = -1
	pass
