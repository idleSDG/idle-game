class_name EquipmentItem extends Resource

enum Slot { WEAPON, ROBE, HAT }

@export var item_name: String = "Unnamed Item"
@export var slot: Slot = Slot.WEAPON

@export var damage_bonus_pct: float = 0.0
@export var ingredient_gain_pct: float = 0.0
@export var crit_rate_bonus: float = 0.0

func _init(name, nSlot: Slot, p_dmg: float = 0.0, p_ing: float = 0.0, p_crit: float = 0.0):
	item_name = name
	slot = nSlot
	damage_bonus_pct = p_dmg
	ingredient_gain_pct = p_ing
	crit_rate_bonus = p_crit
