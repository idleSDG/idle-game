class_name Skill extends Node

var effectScene = load("res://assets/effects/A_EffectScene.tscn")
var skillUI = load("res://scenes/skillUI.tscn")
var skillBar #= skillUI.instantiate()

var skillName = "DefaultSkill"
var levelRequired : int = 1

var potency = 1.0
var maxPotency = 2.0
var equipState : int = -1
var level : int = 0
var experience : int = 0
var max_experience : int = 1000

var charge = 0.0
var maxCharge = 100.0
var element : CharacterStats.Element
var isAoE : bool = false
var isParalyzed : bool = false

var additionalEffect : StatusEffect

var isCurrentAttack : bool = false
var sprite
var borderClr

func _init(p_potency = 1.0, p_max = 100.0, p_element = CharacterStats.Element.None,
		 p_is_aoe : bool = false, p_additionalEffect : StatusEffect = null):
	potency = p_potency
	
	maxCharge = p_max
	element = p_element
	isAoE = p_is_aoe
	additionalEffect = p_additionalEffect
	
	#set_visuals()
	pass

static func CreateSkill(p_skillName : String = "default", p_potency = 1.0, p_maxPotency = 2.0, p_chargeAmount = 100.0,
	 p_element = CharacterStats.Element.None, p_is_aoe : bool = false, p_additionalEffect : StatusEffect = null,
	 lvl = 0, xp = 0, req = 1) -> Skill:
	
	var newSkill : Skill = new(p_potency, p_chargeAmount, p_element, p_is_aoe)
	newSkill.maxPotency = p_maxPotency
	newSkill.level = lvl
	newSkill.experience = xp
	newSkill.additionalEffect = p_additionalEffect
	newSkill.skillName = p_skillName
	newSkill.levelRequired = req
	
	return newSkill

static func DuplicateSkill(prevSkill : Skill) -> Skill:
	var pot = lerp(prevSkill.potency, prevSkill.maxPotency, prevSkill.level / 10.0)
	var newSkill : Skill = new(pot, prevSkill.maxCharge,
	 	prevSkill.element, prevSkill.isAoE, prevSkill.additionalEffect)
	newSkill.skillName = prevSkill.skillName
	newSkill.equipState = prevSkill.equipState
	
	newSkill.set_visuals()
	return newSkill

static func to_dictionary(skill: Skill) -> Dictionary:
	return {
		"name": skill.skillName,
		"lvl": skill.level,
		"xp": skill.experience,
		"equip": skill.equipState,
		"req": skill.levelRequired
	}

static func from_dictionary(skill_str: Dictionary) -> Skill:
	var skill := Skill.FromName(skill_str.name)
	if !skill_str.has("lvl"): return null
	skill.level = skill_str.lvl
	
	if !skill_str.has("xp"): return null
	skill.experience = skill_str.xp
	
	if !skill_str.has("equip"): return null
	skill.equipState = skill_str.equip
	
	if !skill_str.has("req"): return null
	skill.levelRequired = skill_str.req
	
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
	if charge >= maxCharge:
		return charge - maxCharge
	
	return -3

func Use(user : Character, target : Character) -> bool:
	if user == null || target == null:
		return false
	
	var dmg = DamageCalculation(user.baseStats, target.baseStats)
	if isParalyzed:
		dmg.x *= 0.5
	target.TakeDamage(dmg.x, dmg.y > 0.0)
	
	if additionalEffect == null:
		target.play_sfx(Character.SFX_TYPE.MELEE_HIT)
	
	if additionalEffect != null && BattleVariables.battleRNG.randf() < additionalEffect.ApplicationRate:
		if additionalEffect.TargetSelf && isCurrentAttack:
			user.play_status_effect_sfx(additionalEffect.StatusType)
			user.ApplyStatus(StatusEffect.new(additionalEffect.StatusType, 0.0))
		else:
			target.play_status_effect_sfx(additionalEffect.StatusType)
			target.ApplyStatus(StatusEffect.new(additionalEffect.StatusType, 0.0))
	
	if isCurrentAttack:
		charge = charge - maxCharge
	
	var effect = effectScene.instantiate()
	target.get_parent().get_parent().add_child(effect)
	effect.SetUp(target.get_parent().position, element + 1, user.isPlayer)
	
	UpdateBar()
	isCurrentAttack = false
	return true



# Damage formula function
func DamageCalculation(user : CharacterStats, target : CharacterStats) -> Vector2:
	var skillDMG = user.attack * self.potency
	var critCondition = BattleVariables.battleRNG.randf() <= user.critRate
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

func LevelUp(experienceAcquired : int):
	var xpNeeded = max_experience - experience
	if (experienceAcquired > xpNeeded && !(level >= 10)):
		experienceAcquired -= xpNeeded
		experience = 0
		level = level + 1
		LevelUp(experienceAcquired)
	else:
		experience += experienceAcquired
	pass


static func FromName(p_skill_name : String) -> Skill:
	match p_skill_name:
		"Strike" : 
			return Skill.CreateSkill("Strike", 1.0, 2.0, 100.0, CharacterStats.Element.Physical, false,
		 	null, 0, 0, 0)
		"Fireball" : 
			return Skill.CreateSkill("Fireball", 1.2, 2.4, 150.0, CharacterStats.Element.Fire, false,
		 	StatusEffect.new(StatusEffect.StatusEffectType.Burn, 0.5, false), 0, 0, 2)
		"Windstep" : 
			return Skill.CreateSkill("Windstep", 1.0, 2.0, 125.0, CharacterStats.Element.Wind, false,
		 	StatusEffect.new(StatusEffect.StatusEffectType.Haste, 1.0, true), 0, 0, 4)
		"Chill" : 
			return Skill.CreateSkill("Chill", 0.8, 1.6, 150.0, CharacterStats.Element.Ice, false,
		 	StatusEffect.new(StatusEffect.StatusEffectType.Freeze, 1.0, false), 0, 0, 5)
		"Chain Lightning" : 
			return Skill.CreateSkill("Chain Lightning", 0.4, 0.8, 200.0, CharacterStats.Element.Lightning, true,
		 	StatusEffect.new(StatusEffect.StatusEffectType.Paralyze, 0.2, false), 0, 0, 5)
	
	return null
