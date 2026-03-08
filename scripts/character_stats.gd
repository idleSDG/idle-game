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
	InitElemCategory()

static func Create(hp, atk, def, cr, cdmg, charge, elemDmg, elemRes, catDmg, catRes) -> CharacterStats:
	var char : CharacterStats = CharacterStats.new()
	
	char.SetValues(hp, atk, def, cr, cdmg, charge, elemDmg, elemRes, catDmg, catRes)
	char.maxHealth = char.health
	
	return char

static func CreateFromText(line : String):
	# tikriausiai parse'int .CSV faila, kuris veiks kaip musu duombaze
	pass

func SetValues(hp, atk, def, cr, cdmg, charge, elemDmg, elemRes, catDmg, catRes):
	#maxHealth = hp
	health = hp
	attack = atk
	critRate = cr
	critDMG = cdmg
	chargeRate = charge
	SetElemCategory(elemDmg, elemRes, catDmg, catRes)
	pass

func InitElemCategory() :
	for e in Element:
		elementalDMG.append(0.0)
		elementalRES.append(0.0)
	for c in Category:
		categoryDMG.append(0.0)
		categoryRES.append(0.0)
	pass

func SetElemCategory(elemDmg : Array, elemRes : Array, catDmg : Array, catRes : Array) :
	var i : int = 0
	for e in Element:
		if elemDmg.size() > i:
			elementalDMG[i] = elemDmg[i]
		if elemRes.size() > i:
			elementalRES[i] = elemRes[i]
		i += 1
	
	i = 0
	for c in Category:
		if catDmg.size() > i:
			categoryDMG[i] = catDmg[i]
		if catRes.size() > i:
			categoryRES[i] = catRes[i]
		i += 1
	
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
