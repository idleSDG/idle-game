<<<<<<<< HEAD:src/features/battle/status_effect.gd
class_name StatusEffect
extends Node
========
class_name StatusEffect extends Node
>>>>>>>> origin/IG-69-Potion-Crafting-System:src/features/potions/status_effect.gd

var StatusType: StatusEffectType
var ApplicationRate: float = 0.5
var Count: int
var Charge: float = 100.0
var DecrementRate: float = 100.0
var TargetSelf: bool = false


func _init(newType: StatusEffectType, chance: float = 0.0, targetMe: bool = false):
	StatusType = newType
	ApplicationRate = chance
	TargetSelf = targetMe

	match StatusType:
		StatusEffectType.Burn:
			Count = 4
			DecrementRate = 400.0
		StatusEffectType.Freeze:
			Count = 1
			DecrementRate = 25.0
		StatusEffectType.Paralyze:
			Count = 1
			DecrementRate = 0.0
		StatusEffectType.Haste:
			Count = 1
			DecrementRate = 25.0
		StatusEffectType.Strength:
			Count = 1
			DecrementRate = 25.0

	pass


func pass_status_time(delta: float) -> bool:
	Charge -= DecrementRate * delta

	if Charge < 0.0:
		Count -= 1
		Charge += 100.0
		return true

	return false


# Apply is used for effects that activate only at certain points
func Apply(chara: Character):
	match StatusType:
		StatusEffectType.Burn:
			chara.TakeTrueDamage(max(chara.baseStats.health * 0.15, 3), 0)
		StatusEffectType.Freeze:
			pass
		StatusEffectType.Paralyze:
			Count = Count - 1
		StatusEffectType.Haste:
			pass
		StatusEffectType.Strength:
			pass
	pass


# AlterStats is used for status effects that change stat values
func AlterStats(stats: CharacterStats):
	match StatusType:
		StatusEffectType.Burn:
			pass
		StatusEffectType.Freeze:
			stats.chargeRate *= 0.8
			pass
		StatusEffectType.Paralyze:
			pass
		StatusEffectType.Haste:
			stats.chargeRate *= 1.1
			pass
		StatusEffectType.Strength:
			stats.attack *= 1.15
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
		StatusEffectType.Strength:
			return Color.RED

	return Color.WHITE


enum StatusEffectType {
	Burn, # currentHP% damage every 25 charge for 100 charge
	Freeze, # reduces chargeRate by 20% for 100 charge
	Paralyze, # the next spell deals half damage
	Haste, # increases chargeRate by 10% for 100 charge
	Strength, # increase ATK by 15%
}
