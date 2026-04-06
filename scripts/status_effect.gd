class_name  StatusEffect extends Node

var StatusType : StatusEffectType
var ApplicationRate : float = 0.5
var Count : int
var Charge : float = 100.0
var DecrementRate : float = 100.0


func _init(newType : StatusEffectType, chance : float):
	StatusType = newType
	ApplicationRate = chance
	
	match StatusType:
		StatusEffectType.Burn:
			Count = 4
			DecrementRate = 400.0
		StatusEffectType.Freeze:
			Count = 1
			DecrementRate = 100.0
		StatusEffectType.Paralyze:
			Count = 1
			DecrementRate = 0.0
		StatusEffectType.Haste:
			Count = 1
			DecrementRate = 100.0
	
	pass


func pass_status_time(delta : float) -> bool:
	Charge -= DecrementRate * delta
	
	if Charge < 0.0:
		Count -= 1
		Charge += 100.0
		return true
	
	return false

func Apply(chara : Character):
	match StatusType:
		StatusEffectType.Burn:
			chara.TakeTrueDamage(chara.currentStats.health * 0.15, 0)
		StatusEffectType.Freeze:
			pass
		StatusEffectType.Paralyze:
			pass
		StatusEffectType.Haste:
			pass
	pass

func GetColor() -> Color:
	match StatusType:
		StatusEffectType.Burn:
			return Color.ORANGE
		StatusEffectType.Freeze:
			return Color.CYAN
		StatusEffectType.Paralyze:
			return Color.YELLOW
		StatusEffectType.Haste:
			return Color.SPRING_GREEN
	
	return Color.WHITE


enum StatusEffectType 
{
	Burn,     # currentHP% damage every 25 charge for 100 charge
	Freeze,   # reduces chargeRate by 20% for 100 charge
	Paralyze, # the next spell deals less damage
	Haste     # increases chargeRate by 10% for 100 charge
}
