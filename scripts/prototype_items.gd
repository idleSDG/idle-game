class_name PrototypeItems extends Node

static func get_test_items() -> Array:
	var staff = EquipmentItem.new("Novice Staff", EquipmentItem.Slot.WEAPON)
	staff.attack_bonus_pct = 0.8

	var ROBE = EquipmentItem.new("Gatherer's Robe", EquipmentItem.Slot.ROBE)
	ROBE.ingredient_gain_bonus_pct = 1.5

	var hat = EquipmentItem.new("Wizard's Hat", EquipmentItem.Slot.HAT)
	hat.crit_rate_bonus_pct = 0.5

	return [staff, ROBE, hat]
