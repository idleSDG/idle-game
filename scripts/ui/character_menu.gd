extends Node

@onready var weapon_btn       : Button         = $CanvasLayer/HSplit/RightVBox/EquipSection/WeaponSlotBtn
@onready var robe_btn         : Button         = $CanvasLayer/HSplit/RightVBox/EquipSection/RobeSlotBtn
@onready var hat_btn          : Button         = $CanvasLayer/HSplit/RightVBox/EquipSection/HatSlotBtn
@onready var stat_bonus_label : Label          = $CanvasLayer/HSplit/RightVBox/EquipSection/StatBonusLabel
@onready var skin_panel       : SkinColorPanel = $CanvasLayer/HSplit/RightVBox/CosmeticsSection/SkinColorPanel

var _items : Array = PrototypeItems.get_test_items()

func _ready() -> void:
	_refresh_equipment_buttons()

	weapon_btn.pressed.connect(_on_weapon_pressed)
	robe_btn.pressed.connect(_on_robe_pressed)
	hat_btn.pressed.connect(_on_hat_pressed)

	skin_panel.changed.connect(_on_skin_color_changed)

	# Only need to refresh the buttons and stats label here —
	# WizardAvatar handles its own visual refresh via signals
	EquipmentManager.equipment_changed.connect(_refresh_equipment_buttons)

func _toggle_slot(slot: EquipmentItem.Slot) -> void:
	if EquipmentManager.get_equipped(slot) != null:
		EquipmentManager.unequip(slot)
	else:
		for item in _items:
			if item.slot == slot:
				EquipmentManager.equip(item)
				break

func _on_weapon_pressed() -> void: _toggle_slot(EquipmentItem.Slot.WEAPON)
func _on_robe_pressed()   -> void: _toggle_slot(EquipmentItem.Slot.ROBE)
func _on_hat_pressed()    -> void: _toggle_slot(EquipmentItem.Slot.HAT)

func _refresh_equipment_buttons() -> void:
	var w := EquipmentManager.get_equipped(EquipmentItem.Slot.WEAPON)
	var r := EquipmentManager.get_equipped(EquipmentItem.Slot.ROBE)
	var h := EquipmentManager.get_equipped(EquipmentItem.Slot.HAT)

	weapon_btn.text = "Staff : " + (w.item_name if w else "None  [tap to equip]")
	robe_btn.text   = "Robe  : " + (r.item_name if r else "None  [tap to equip]")
	hat_btn.text    = "Hat   : " + (h.item_name if h else "None  [tap to equip]")

	var bonuses := EquipmentManager.get_total_bonuses()
	stat_bonus_label.text = "DMG +%d%%\nIngredient +%d%%\nCrit +%d%%" % [
		bonuses["damage_bonus_pct"]    * 100,
		bonuses["ingredient_gain_pct"] * 100,
		bonuses["crit_rate_bonus"]     * 100,
	]

func _on_skin_color_changed(color: Color) -> void:
	PlayerAppearance.apply_skin_color(color)
