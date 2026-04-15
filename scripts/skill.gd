class_name Skill extends Node

var skillUI = load("res://scenes/skillUI.tscn")
var skillBar #= skillUI.instantiate()

var skillName = "DefaultSkill"

var potency = 1.0
var maxPotency = 2.0
var equipState : int = -1
var level : int = 0
var exp : int = 0
var maxExp : int = 1000

var charge = 0.0
var maxCharge = 100.0
var element : CharacterStats.Element
var isAoE : bool = false
var isParalyzed : bool = false

var additionalEffect : StatusEffect

var isCurrentAttack : bool = false
var sprite
var borderClr


func _init(pot = 1.0, max = 100.0, elem = CharacterStats.Element.None,
		 aoe : bool = false, addEffect : StatusEffect = null):
	potency = pot
	
	maxCharge = max
	element = elem
	isAoE = aoe
	additionalEffect = addEffect
	
	#set_visuals()
	pass

static func CreateSkill(name : String = "default", pot = 1.0, maxPot = 2.0, chargeAmnt = 100.0,
	 elem = CharacterStats.Element.None, aoe : bool = false, addEffect : StatusEffect = null,
	 lvl = 0, xp = 0) -> Skill:
	
	var newSkill : Skill = new(pot, chargeAmnt, elem, aoe)
	newSkill.maxPotency = maxPot
	newSkill.level = lvl
	newSkill.exp = xp
	newSkill.additionalEffect = addEffect
	newSkill.skillName = name
	
	return newSkill

static func DuplicateSkill(prevSkill : Skill) -> Skill:
	var pot = lerp(prevSkill.potency, prevSkill.maxPotency, prevSkill.level / 10.0)
	var newSkill : Skill = new(pot, prevSkill.maxCharge,
	 	prevSkill.element, prevSkill.isAoE, prevSkill.additionalEffect)
	newSkill.skillName = prevSkill.skillName
	
	newSkill.set_visuals()
	return newSkill

static func to_dictionary(skill: Skill) -> Dictionary:
	return {
		"name": skill.skillName,
		"lvl": skill.level,
		"xp": skill.exp,
		"equip": skill.equipState
	}

static func from_dictionary(skill_str: Dictionary) -> Skill:
	var skill := Skill.FromName(skill_str.name)
	skill.level = skill_str.lvl
	skill.exp = skill_str.xp
	skill.equipState = skill_str.equip
	
	return skill


func addEffect(type : StatusEffect.StatusEffectType, chance : float, targetSelf : bool):
	var status = StatusEffect.new(type, chance, targetSelf)
	additionalEffect = status
	pass


func UpdateBar():
	skillBar.value = clamp(charge / maxCharge, 0.0, 1.0)
	pass

func Charge(delta: float) -> bool:
	charge += delta * 100
	isCurrentAttack = true
	UpdateBar()
	
	return false

func GetOvercharge() -> float:
	if charge > maxCharge:
		return charge - maxCharge
	
	return -3

func Use(user : Character, target : Character) -> bool:
	if user == null || target == null:
		return false
	
	var dmg = DamageCalculation(user.baseStats, target.baseStats)
	if isParalyzed:
		dmg.x *= 0.5
	target.TakeDamage(dmg.x, dmg.y > 0.0)
	
	if additionalEffect != null && RandomNumberGenerator.new().randf() < additionalEffect.ApplicationRate:
		if additionalEffect.TargetSelf && isCurrentAttack:
			user.ApplyStatus(StatusEffect.new(additionalEffect.StatusType, 0.0))
		else:
			target.ApplyStatus(StatusEffect.new(additionalEffect.StatusType, 0.0))
	
	if isCurrentAttack:
		charge -= maxCharge
	
	UpdateBar()
	isCurrentAttack = false
	return true

# Damage formula function
func DamageCalculation(user : CharacterStats, target : CharacterStats) -> Vector2:
	var bonuses = EquipmentManager.get_total_bonuses()
	var skillDMG = user.attack * self.potency * (1.0 + bonuses["damage_bonus_pct"])
	var critCondition = RandomNumberGenerator.new().randf() <= (user.critRate + bonuses["crit_rate_bonus"])
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


func set_visuals():
	skillBar = skillUI.instantiate()
	
	get_images()
	
	skillBar.get_node("TextureRect").modulate = borderClr
	skillBar.texture_progress = sprite
	skillBar.texture_under = sprite
	
	pass

func get_images():
	match element:
		CharacterStats.Element.None:
			sprite = load("res://assets/skills/None2_borderless.png")
			borderClr = Color.WHITE
		CharacterStats.Element.Fire:
			sprite = load("res://assets/skills/Fire_borderless.png")
			borderClr = Color.ORANGE_RED
		CharacterStats.Element.Ice:
			sprite = load("res://assets/skills/Ice_borderless.png")
			borderClr = Color.SKY_BLUE
		CharacterStats.Element.Lightning:
			sprite = load("res://assets/skills/Lightning_borderless.png")
			borderClr = Color.YELLOW
		CharacterStats.Element.Wind:
			sprite = load("res://assets/skills/Wind_borderless.png")
			borderClr = Color.SPRING_GREEN
		CharacterStats.Element.Physical:
			sprite = load("res://assets/skills/Physical_borderless.png")
			borderClr = Color.GOLDENROD

func LevelUp(expAcquired : int):
	var xpNeeded = maxExp - exp
	if (expAcquired > xpNeeded && !(level >= 10)):
		expAcquired -= xpNeeded
		exp = 0
		level = level + 1
		LevelUp(expAcquired)
	else:
		exp += expAcquired
	pass


static func FromName(name : String) -> Skill:
	match name:
		"Strike" : 
			return Skill.CreateSkill("Strike", 1.0, 2.0, 100.0, CharacterStats.Element.Physical, false, null, 0, 0)
		"Fireball" : 
			return Skill.CreateSkill("Fireball", 1.2, 2.4, 150.0, CharacterStats.Element.Fire, false,
		 	StatusEffect.new(StatusEffect.StatusEffectType.Burn, 0.5, false), 0, 0)
		"Windstep" : 
			return Skill.CreateSkill("Windstep", 1.0, 2.0, 125.0, CharacterStats.Element.Wind, false,
		 	StatusEffect.new(StatusEffect.StatusEffectType.Haste, 1.0, true), 0, 0)
		"Chill" : 
			return Skill.CreateSkill("Chill", 0.8, 1.6, 150.0, CharacterStats.Element.Ice, false,
		 	StatusEffect.new(StatusEffect.StatusEffectType.Freeze, 1.0, false), 0, 0)
		"Chain Lightning" : 
			return Skill.CreateSkill("Chain Lightning", 0.4, 0.8, 200.0, CharacterStats.Element.Lightning, true,
		 	StatusEffect.new(StatusEffect.StatusEffectType.Paralyze, 0.2, false), 0, 0)
	
	return null
