class_name Skill extends Node

var skillUI = load("res://scenes/skillUI.tscn")
var skillBar = skillUI.instantiate()

var charge = 0.0
var maxCharge = 100.0

var potency = 1.0
var element : CharacterStats.Element


func _init(max : float):
	maxCharge = max
	pass

func UpdateBar():
	skillBar.value = clamp(charge / maxCharge, 0.0, 1.0)
	pass

func Charge(delta: float) -> bool:
	charge += delta * 100
	UpdateBar()
	
	return false

func GetOvercharge() -> float:
	if charge > maxCharge:
		return charge - maxCharge
	
	return -3


func Use(user : Character, target : Character) -> bool:
	var dmg = DamageCalculation(user.currentStats, target.currentStats)
	target.TakeDamage(dmg.x, dmg.y > 0.0)
	
	
	charge -= maxCharge
	UpdateBar()
	
	return true

func DamageCalculation(user : CharacterStats, target : CharacterStats) -> Vector2:
	var skillDMG = user.attack * self.potency
	var critCondition = RandomNumberGenerator.new().randf() <= user.critRate
	var critMult = 1.0 + user.critDMG if critCondition else 1.0
	var elementMult = 1.0 + user.elementalDMG[self.element]
	var categoryMult = 1.0 + user.categoryDMG[target.characterCategory]
	
	var defenseRes = 10000.0 / (10000.0 + target.defense)
	var elementRes = 1.0 - target.elementalRES[self.element]
	var categoryRes = 1.0 - target.categoryRES[user.characterCategory]
	
	#var targetMit = getMitigationSources   - - - -- - -      NOT IMPLEMENTED
	
	var dealtDMG = (skillDMG * critMult * elementMult * categoryMult)
	dealtDMG = dealtDMG * (defenseRes * elementRes * categoryRes)
	
	return Vector2(floor(dealtDMG), 1.0 if critCondition else -1.0)
