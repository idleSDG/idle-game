class_name CharacterStats extends Object

var characterCategory : Category

var maxHealth : int = 100
var health : int = maxHealth
var attack : int = 10
var defense : int = 10

var critRate = 0.05
var critDMG = 0.5
var chargeRate = 1.0

var elementalDMG = []
var elementalRES = []

var categoryDMG = []
var categoryRES = []


func _init():
	InitElemCategory()

# Create a new character stats object from all of its variables
static func Create(hp, atk, def, cr, cdmg, charge, elemDmg, elemRes, catDmg, catRes) -> CharacterStats:
	var char : CharacterStats = CharacterStats.new()
	
	char.SetValues(hp, atk, def, cr, cdmg, charge, elemDmg, elemRes, catDmg, catRes)
	char.maxHealth = char.health
	
	return char

# Parse string to create a new character stats object
static func CreateFromText(line : String):
	# tikriausiai parse'int .CSV faila, kuris veiks kaip musu duombaze
	pass

# Sets the values of an already existing characterStats object
func SetValues(hp, atk, def, cr, cdmg, charge, elemDmg, elemRes, catDmg, catRes):
	#maxHealth = hp
	health = hp
	attack = atk
	critRate = cr
	critDMG = cdmg
	chargeRate = charge
	SetElemCategory(elemDmg, elemRes, catDmg, catRes)
	pass

func CalculateFinalStats(baseStats : CharacterStats):
	self.SetValues(baseStats.health, baseStats.attack + self.attack, baseStats.defense + self.defense,
		baseStats.critRate + self.critRate, baseStats.critDMG + self.critDMG,
		baseStats.chargeRate * self.chargeRate,
		baseStats.elementalDMG, baseStats.elementalRES, baseStats.categoryDMG, baseStats.categoryRES)
	pass


func ResetStats():
	self.SetValues(0, 0, 0, 0, 0, 0, [], [], [], [])
	pass

# Sets up DMG and RES fields with 0.0 values
func InitElemCategory() :
	for e in Element:
		elementalDMG.append(0.0)
		elementalRES.append(0.0)
	for c in Category:
		categoryDMG.append(0.0)
		categoryRES.append(0.0)
	pass

# Sets the values of DMG and RES fields
func SetElemCategory(elemDmg : Array, elemRes : Array, catDmg : Array, catRes : Array) :
	var i : int = 0
	for e in Element:
		if elemDmg.size() > i:
			elementalDMG[i] = elemDmg[i]
		else:
			elementalDMG[i] = 0.0
		
		if elemRes.size() > i:
			elementalRES[i] = elemRes[i]
		else:
			elementalRES[i] = 0.0
			
		i += 1
	
	i = 0
	for c in Category:
		if catDmg.size() > i:
			categoryDMG[i] = catDmg[i]
		else:
			categoryDMG[i] = 0.0
		
		if catRes.size() > i:
			categoryRES[i] = catRes[i]
		else:
			categoryRES[i] = 0.0
			
		i += 1
	
	pass


# Subtract damageTaken from health
func TakeDamage(dmgTaken : int) :
	health -= dmgTaken
	health = clamp(health, 0, maxHealth)
	
	return


enum Element 
{
	None, Fire, Ice, Lightning, Wind, Physical
}

enum Category
{
	None, Wizard, Beast, Undead, Draconian
}
