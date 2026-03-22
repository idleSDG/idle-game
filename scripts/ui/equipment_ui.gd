extends Node

@onready var weapon_btn = $CanvasLayer/VBoxContainer/WeaponSlotBtn
@onready var belt_btn   = $CanvasLayer/VBoxContainer/BeltSlotBtn
@onready var hat_btn    = $CanvasLayer/VBoxContainer/HatSlotBtn
@onready var stats_lbl  = $CanvasLayer/VBoxContainer/StatBonusLabel

var PrototypeItems = load("res://scripts/prototype_items.gd")
var items = PrototypeItems.get_test_items()

func _ready():
	# Load items from the prototype items file
	EquipmentManager.equipment_changed.connect(_refresh_ui)
	_refresh_ui()
	# Setup button signals
	weapon_btn.pressed.connect(_on_weapon_slot_btn_pressed)
	belt_btn.pressed.connect(_on_belt_slot_btn_pressed)
	hat_btn.pressed.connect(_on_hat_slot_btn_pressed)

func _refresh_ui():
	var equipped_weapon = EquipmentManager.get_equipped(EquipmentItem.Slot.WEAPON)
	var equipped_belt   = EquipmentManager.get_equipped(EquipmentItem.Slot.BELT)
	var equipped_hat    = EquipmentManager.get_equipped(EquipmentItem.Slot.HAT)

	weapon_btn.text = "Weapon: " + (equipped_weapon.item_name if equipped_weapon else "None")
	belt_btn.text   = "Belt: "   + (equipped_belt.item_name if equipped_belt else "None")
	hat_btn.text    = "Hat: "    + (equipped_hat.item_name if equipped_hat else "None")

	var bonuses = EquipmentManager.get_total_bonuses()
	stats_lbl.text = "DMG +%d%% | Ingredient +%d%% | Crit +%d%%" % [
		bonuses["damage_bonus_pct"] * 100,
		bonuses["ingredient_gain_pct"] * 100,
		bonuses["crit_rate_bonus"] * 100,
	]

func _on_weapon_slot_btn_pressed():
	# If slot filled, unequip; else equip first weapon from "items"
	var current = EquipmentManager.get_equipped(EquipmentItem.Slot.WEAPON)
	if current:
		EquipmentManager.unequip(EquipmentItem.Slot.WEAPON)
	else:
		for item in items:
			if item.slot == EquipmentItem.Slot.WEAPON:
				EquipmentManager.equip(item)
				break

func _on_belt_slot_btn_pressed():
	var current = EquipmentManager.get_equipped(EquipmentItem.Slot.BELT)
	if current:
		EquipmentManager.unequip(EquipmentItem.Slot.BELT)
	else:
		for item in items:
			if item.slot == EquipmentItem.Slot.BELT:
				EquipmentManager.equip(item)
				break

func _on_hat_slot_btn_pressed():
	var current = EquipmentManager.get_equipped(EquipmentItem.Slot.HAT)
	if current:
		EquipmentManager.unequip(EquipmentItem.Slot.HAT)
	else:
		for item in items:
			if item.slot == EquipmentItem.Slot.HAT:
				EquipmentManager.equip(item)
				break
