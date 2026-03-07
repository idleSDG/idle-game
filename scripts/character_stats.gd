class_name CharacterStats extends Object

var characterCategory : Category

var maxHealth : int = 100
var health : int = maxHealth
var attack : int = 10
var defense : int = 10

var critRate = 0.5
var critDMG = 0.5
var chargeRate = 1.0

var elementalDMG = []
var elementalRES = []

var categoryDMG = []
var categoryRES = []


func _init():
	SetUpElementCategory()

func SetUpElementCategory() :
	for e in Element:
		elementalDMG.append(0.0)
		elementalRES.append(0.0)
	for c in Category:
		categoryDMG.append(0.0)
		categoryRES.append(0.0)
	pass


func TakeDamage(dmgTaken : int) :
	health -= dmgTaken
	health = clamp(health, 0, maxHealth)
	
	#print("Damage taken: ", floor(dmgTaken))
	#print("Health remaining: ", health)
	
	return


enum Element 
{
	None, Fire, Ice, Lightning, Wind, Physical
}

enum Category
{
	None, Wizard, Beast, Undead, Draconian
}
