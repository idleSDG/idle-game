class_name Skill extends Node

var charge = 0
var maxCharge = 100

var potency = 1.0
var element : CharacterStats.Element


func _init(max : float):
	maxCharge = max
	pass
	

func Charge(delta: float) -> bool:
	charge += delta * 100
	
	return false

func GetOvercharge() -> float:
	if charge > maxCharge:
		return charge - maxCharge
	
	return -3


func Use(user : Character, target : Character) -> bool:
	DamageCalculation(user.currentStats, target.currentStats)
	
	charge -= maxCharge
	return true

func DamageCalculation(user : CharacterStats, target : CharacterStats) :
	var skillDMG = user.attack * self.potency
	var critMult = 1.0 + user.critDMG if RandomNumberGenerator.new().randf() <= user.critRate else 1.0
	var elementMult = 1.0 + user.elementalDMG[self.element]
	var categoryMult = 1.0 + user.categoryDMG[target.characterCategory]
	
	var defenseRes = 10000.0 / (10000.0 + target.defense)
	var elementRes = 1.0 - target.elementalRES[self.element]
	var categoryRes = 1.0 - target.categoryRES[user.characterCategory]
	#var targetMit = getMitigationSources   - - - -- - -      NOT IMPLEMENTED
	
	var dealtDMG = (skillDMG * critMult * elementMult * categoryMult)
	dealtDMG = dealtDMG * (defenseRes * elementRes * categoryRes)
	
	target.TakeDamage(dealtDMG)
	
	pass
