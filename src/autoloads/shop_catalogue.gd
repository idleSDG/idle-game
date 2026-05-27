extends Node

var items: Array[EquipmentItem] = []

func _ready() -> void:
	_build_catalogue()

func _build_catalogue() -> void:
	# Weapons - focus on ATK
	var weap1 = EquipmentItem.new("Stick Staff", EquipmentItem.Slot.WEAPON)
	weap1.attack_bonus_pct = 0.3
	weap1.calculate_cost()
	weap1.icon = preload("res://assets/icons/equipment/staff1.png")
	weap1.sprite = preload("res://assets/equipment/staff1.png")

	var weap2 = EquipmentItem.new("Magical Staff", EquipmentItem.Slot.WEAPON)
	weap2.attack_bonus_pct = 0.6
	weap2.crit_rate_bonus_pct = 0.15
	weap2.calculate_cost()
	weap2.icon = preload("res://assets/icons/equipment/staff2.png")
	weap2.sprite = preload("res://assets/equipment/staff2.png")

	var weap3 = EquipmentItem.new("Great Staff", EquipmentItem.Slot.WEAPON)
	weap3.attack_bonus_pct = 1.0
	weap3.crit_rate_bonus_pct = 0.2
	weap3.crit_dmg_bonus_pct = 0.3
	weap3.calculate_cost()
	weap3.icon = preload("res://assets/icons/equipment/staff3.png")
	weap3.sprite = preload("res://assets/equipment/staff3.png")

	# Robes - focus on ingredient gain and survivability
	var robe1 = EquipmentItem.new("Basic Robe", EquipmentItem.Slot.ROBE)
	robe1.ingredient_gain_bonus_pct = 0.3
	robe1.calculate_cost()
	robe1.icon = preload("res://assets/icons/equipment/robe1.png")
	robe1.sprite = preload("res://assets/equipment/robe1.png")

	var robe2 = EquipmentItem.new("Apprentice Robe", EquipmentItem.Slot.ROBE)
	robe2.ingredient_gain_bonus_pct = 0.5
	robe2.health_bonus_pct = 0.2
	robe2.calculate_cost()
	robe2.icon = preload("res://assets/icons/equipment/robe2.png")
	robe2.sprite = preload("res://assets/equipment/robe2.png")

	var robe3 = EquipmentItem.new("Master Robe", EquipmentItem.Slot.ROBE)
	robe3.ingredient_gain_bonus_pct = 0.8
	robe3.health_bonus_pct = 0.3
	robe3.defense_bonus_pct = 0.2
	robe3.calculate_cost()
	robe3.icon = preload("res://assets/icons/equipment/robe3.png")
	robe3.sprite = preload("res://assets/equipment/robe3.png")

	# Hats - focus on crit
	var hat1 = EquipmentItem.new("Pointy Hat", EquipmentItem.Slot.HAT)
	hat1.crit_rate_bonus_pct = 0.3
	hat1.calculate_cost()
	hat1.icon = preload("res://assets/icons/equipment/hat1.png")
	hat1.sprite = preload("res://assets/equipment/hat1.png")

	var hat2 = EquipmentItem.new("Sorcerer's Hat", EquipmentItem.Slot.HAT)
	hat2.crit_rate_bonus_pct = 0.4
	hat2.crit_dmg_bonus_pct = 0.3
	hat2.calculate_cost()
	hat2.icon = preload("res://assets/icons/equipment/hat2.png")
	hat2.sprite = preload("res://assets/equipment/hat2.png")

	var hat3 = EquipmentItem.new("Archmage's Hat", EquipmentItem.Slot.HAT)
	hat3.crit_rate_bonus_pct = 0.5
	hat3.crit_dmg_bonus_pct = 0.5
	hat3.attack_bonus_pct = 0.2
	hat3.calculate_cost()
	hat3.icon = preload("res://assets/icons/equipment/hat3.png")
	hat3.sprite = preload("res://assets/equipment/hat3.png")

	items = [weap1, weap2, weap3, robe1, robe2, robe3, hat1, hat2, hat3]

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