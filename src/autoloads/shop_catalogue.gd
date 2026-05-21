extends Node

var items: Array[EquipmentItem] = []


func _ready() -> void:
	_build_catalogue()


func _build_catalogue() -> void:
	# Weapons
	var weap2 = EquipmentItem.new("weap2", EquipmentItem.Slot.WEAPON)
	weap2.attack_bonus_pct = 0.5
	weap2.calculate_cost()

	var weap3 = EquipmentItem.new("weap3", EquipmentItem.Slot.WEAPON)
	weap3.attack_bonus_pct = 0.8
	weap3.crit_rate_bonus_pct = 0.2
	weap3.calculate_cost()

	var weap4 = EquipmentItem.new("weap4", EquipmentItem.Slot.WEAPON)
	weap4.attack_bonus_pct = 1.2
	weap4.crit_dmg_bonus_pct = 0.3
	weap4.calculate_cost()

	var weap5 = EquipmentItem.new("weap5", EquipmentItem.Slot.WEAPON)
	weap5.attack_bonus_pct = 1.9
	weap5.crit_rate_bonus_pct = 0.3
	weap5.crit_dmg_bonus_pct = 0.5
	weap5.calculate_cost()

	# Robes
	var robe2 = EquipmentItem.new("robe2", EquipmentItem.Slot.ROBE)
	robe2.ingredient_gain_bonus_pct = 0.5
	robe2.calculate_cost()

	var robe3 = EquipmentItem.new("robe3", EquipmentItem.Slot.ROBE)
	robe3.ingredient_gain_bonus_pct = 1.0
	robe3.health_bonus_pct = 0.2
	robe3.calculate_cost()

	var robe4 = EquipmentItem.new("robe4", EquipmentItem.Slot.ROBE)
	robe4.ingredient_gain_bonus_pct = 1.7
	robe4.health_bonus_pct = 0.3
	robe4.defense_bonus_pct = 0.2
	robe4.calculate_cost()

	# Hats
	var hat2 = EquipmentItem.new("hat2", EquipmentItem.Slot.HAT)
	hat2.crit_rate_bonus_pct = 0.5
	hat2.calculate_cost()

	var hat3 = EquipmentItem.new("hat3", EquipmentItem.Slot.HAT)
	hat3.crit_rate_bonus_pct = 1.0
	hat3.crit_dmg_bonus_pct = 0.3
	hat3.calculate_cost()

	var hat4 = EquipmentItem.new("hat4", EquipmentItem.Slot.HAT)
	hat4.crit_rate_bonus_pct = 1.5
	hat4.crit_dmg_bonus_pct = 0.5
	hat4.attack_bonus_pct = 0.2
	hat4.calculate_cost()

	var hat5 = EquipmentItem.new("hat5", EquipmentItem.Slot.HAT)
	hat5.crit_rate_bonus_pct = 2.0
	hat5.crit_dmg_bonus_pct = 0.8
	hat5.attack_bonus_pct = 0.3
	hat5.defense_bonus_pct = 0.2
	hat5.calculate_cost()

	items = [weap2, weap3, weap4, weap5, robe2, robe3, robe4, hat2, hat3, hat4, hat5]


func is_owned(item: EquipmentItem) -> bool:
	for owned in PlayerInventory.equipment:
		if owned.item_name == item.item_name:
			return true
	return false


func find_by_name(item_name: String) -> EquipmentItem:
	for item in items:
		if item.item_name == item_name:
			return item
	return null
