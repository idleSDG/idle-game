extends Node

signal equipment_changed

# Store equipped items by slot
var equipped: Dictionary = {
	EquipmentItem.Slot.WEAPON: null,
	EquipmentItem.Slot.BELT:   null,
	EquipmentItem.Slot.HAT:    null,
}

func equip(item: EquipmentItem) -> void:
	equipped[item.slot] = item
	emit_signal("equipment_changed")

func unequip(slot: EquipmentItem.Slot) -> void:
	equipped[slot] = null
	emit_signal("equipment_changed")

func get_equipped(slot: EquipmentItem.Slot) -> EquipmentItem:
	return equipped[slot]

func get_total_bonuses() -> Dictionary:
	var bonuses = {
		"damage_bonus_pct": 0.0,
		"ingredient_gain_pct": 0.0,
		"crit_rate_bonus": 0.0,
	}
	for item in equipped.values():
		if item != null:
			bonuses["damage_bonus_pct"]     += item.damage_bonus_pct
			bonuses["ingredient_gain_pct"]  += item.ingredient_gain_pct
			bonuses["crit_rate_bonus"]      += item.crit_rate_bonus
	return bonuses
