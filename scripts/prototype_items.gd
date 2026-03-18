class_name PrototypeItems extends Node

static func get_test_items() -> Array:
	var staff = EquipmentItem.new()
	staff.item_name = "Novice Staff"
	staff.slot = EquipmentItem.Slot.WEAPON
	staff.damage_bonus_pct = 0.10

	var belt = EquipmentItem.new()
	belt.item_name = "Gatherer's Belt"
	belt.slot = EquipmentItem.Slot.BELT
	belt.ingredient_gain_pct = 0.05

	var hat = EquipmentItem.new()
	hat.item_name = "Wizard's Hat"
	hat.slot = EquipmentItem.Slot.HAT
	hat.crit_rate_bonus = 0.02

	return [staff, belt, hat]
