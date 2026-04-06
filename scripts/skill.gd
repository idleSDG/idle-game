class_name Skill extends Node

var skillUI = load("res://scenes/skillUI.tscn")
var skillBar = skillUI.instantiate()

var skillName = "DefaultSkill"

var charge = 0.0
var maxCharge = 100.0
var potency = 1.0
var element : CharacterStats.Element
var isAoE : bool = false

var additionalEffect : StatusEffect


var sprite
var borderClr


func _init(pot = 1.0, max = 100.0, elem = CharacterStats.Element.None, aoe : bool = false):
	potency = pot
	maxCharge = max
	element = elem
	isAoE = aoe
	set_visuals()
	
	pass

func addEffect(type : StatusEffect.StatusEffectType, chance : float):
	var status = StatusEffect.new(type, chance)
	additionalEffect = status
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
	
	if additionalEffect != null && RandomNumberGenerator.new().randf() < additionalEffect.ApplicationRate:
		target.ApplyStatus(additionalEffect)
	
	charge -= maxCharge
	UpdateBar()
	
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
	
	skillBar.get_node("TextureRect").modulate = borderClr
	skillBar.texture_progress = sprite
	skillBar.texture_under = sprite
	
	pass
