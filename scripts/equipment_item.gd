class_name EquipmentItem extends Resource

enum Slot { WEAPON, BELT, HAT }

@export var item_name: String = "Unnamed Item"
@export var slot: Slot = Slot.WEAPON

@export var damage_bonus_pct: float = 0.0
@export var ingredient_gain_pct: float = 0.0
@export var crit_rate_bonus: float = 0.0

func _init(name, nSlot : Slot):
	item_name = name
	slot = nSlot
	pass
