class_name Potion extends Node

enum PotionTypes { Status, Damage }

var effectScene = load("res://assets/effects/A_EffectScene.tscn")

const _icon_array = [
	preload("res://assets/icons/potions/potion_explosion_icon.tres"),
	preload("res://assets/icons/potions/potion_health_icon.tres"),
	preload("res://assets/icons/potions/potion_strength_icon.tres")
]

var id : int
var slot : int = -1
var quantity : int = 10
var icon: Texture2D

var type : PotionTypes
var potName : String = ""
var recipe_description : String = ""
var recipe: Array[Dictionary] = [] # Should be created as pairs.

var damage : int = 50
var cooldown : float = 10.0
var currentCooldown : float
var effect : StatusEffect
var targetSelf : bool = true

var posit : Vector2


func _init(newId : int, slt : int = -1):
	id = newId
	slot = slt
	icon = _icon_array[newId]
	
	match id:
		0: 
			potName = "Explosive Potion"
			type = PotionTypes.Damage
			damage = 50
			cooldown = 2.0
			currentCooldown = 0.0
			targetSelf = false
			recipe_description = "A explosive concoction that oddly smells like oranges? Deals [color=#FF0000]%d damage[/color] to all enemies." % damage
			recipe = [{"type": Ingredient.Type.KINETIC_SHARD, "amount": 5}, {"type": Ingredient.Type.FOCUS_FLUX, "amount": 5}]
		1: 
			potName = "Healing Potion"
			type = PotionTypes.Damage
			damage = -50
			cooldown = 2.0
			currentCooldown = 0.0
			targetSelf = true
			recipe_description = "The most basic Healing potion, known even by novice wizards. Heals [color=#AAFF00]%d health[/color]. Tastes like apples?" % [-damage]
			recipe = [{"type": Ingredient.Type.FOCUS_FLUX, "amount": 3}, {"type": Ingredient.Type.DREAM_SHARDS, "amount": 2}]
		2: 
			potName = "Strength Potion"
			type = PotionTypes.Status
			effect = StatusEffect.new(StatusEffect.StatusEffectType.Strength, 1.0, true)
			cooldown = 100.0 / effect.DecrementRate
			currentCooldown = 0.0
			targetSelf = true
			recipe_description = "A bubbly black-ish elixir that tastes like victory and questionable decisions. Applies [color=#FFA500]STRENGTH[/color] to your wizard."
			recipe = [{"type": Ingredient.Type.DREAM_SHARDS, "amount": 4}, {"type": Ingredient.Type.KINETIC_SHARD, "amount": 6}]

func UsePotion(charList : Array[Character]):
	UsePotionEffect(charList)
	PotionManager.GetPotionSlot(slot).quantity -= 1
	
	pass

func UsePotionEffect(charList : Array[Character]):
	if type == PotionTypes.Damage:
		if targetSelf:
			charList[0].TakeTrueDamage(damage, 1)
			charList[0].play_sfx(Character.SFX_TYPE.HEAL)
		else:
			charList[1].play_sfx(Character.SFX_TYPE.EXPLOSION)
			if charList[1] != null: charList[1].TakeTrueDamage(damage, 1)
			if charList[2] != null: charList[2].TakeTrueDamage(damage, 1)
			if charList[3] != null: charList[3].TakeTrueDamage(damage, 1)
			
			var effect = effectScene.instantiate()
			charList[0].get_parent().get_parent().add_child(effect)
			effect.SetUp(posit + Vector2(0, -100), 0)
	
	if type == PotionTypes.Status:
		if targetSelf:
			charList[0].ApplyStatus(effect)
			charList[0].play_status_effect_sfx(effect.StatusType)
		else:
			if charList[1] != null: 
				charList[1].ApplyStatus(effect)
				charList[1].play_status_effect_sfx(effect.StatusType)
			if charList[2] != null: 
				charList[2].ApplyStatus(effect)
				charList[2].play_status_effect_sfx(effect.StatusType)
			if charList[3] != null: 
				charList[3].ApplyStatus(effect)
				charList[3].play_status_effect_sfx(effect.StatusType)
	
	currentCooldown = cooldown

func PassTime(delta : float):
	if currentCooldown > 0.0:
		currentCooldown = max(currentCooldown - delta, 0.0)
	pass
	

static func to_dictionary(pot: Potion) -> Dictionary:
	return {
		"id": pot.id,
		"quantity": pot.quantity,
		"slot": pot.slot
	}

static func from_dictionary(skill_str: Dictionary) -> Potion:
	var potion := Potion.new(skill_str.id, skill_str.slot)
	potion.quantity = skill_str.quantity
	
	return potion
