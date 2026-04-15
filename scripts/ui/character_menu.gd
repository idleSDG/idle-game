extends Node

@onready var weapon_btn : Button = $CanvasLayer/HSplit/RightVBox/EquipSection/WeaponSlotBtn
@onready var robe_btn : Button = $CanvasLayer/HSplit/RightVBox/EquipSection/RobeSlotBtn
@onready var hat_btn : Button = $CanvasLayer/HSplit/RightVBox/EquipSection/HatSlotBtn
@onready var stat_bonus_label : Label = $CanvasLayer/HSplit/RightVBox/EquipSection/StatBonusLabel
@onready var skin_panel : SkinColorPanel = $CanvasLayer/HSplit/RightVBox/CosmeticsSection/SkinColorPanel

# Item picker overlay
@onready var item_picker : Control = $CanvasLayer/ItemPicker
@onready var item_grid : ItemGrid  = $CanvasLayer/ItemPicker/VBox/ItemGrid
@onready var picker_title : Label = $CanvasLayer/ItemPicker/VBox/PickerTitle
@onready var picker_close_btn : Button = $CanvasLayer/ItemPicker/VBox/CloseBtn

var _current_picker_slot : EquipmentItem.Slot

func _ready() -> void:
	_refresh_equipment_buttons()
	item_picker.visible = false

	weapon_btn.pressed.connect(_on_weapon_pressed)
	robe_btn.pressed.connect(_on_robe_pressed)
	hat_btn.pressed.connect(_on_hat_pressed)

	skin_panel.changed.connect(_on_skin_color_changed)
	picker_close_btn.pressed.connect(_close_picker)

	item_grid.equipment_pressed.connect(_on_item_selected)
	item_grid.unequip_pressed.connect(_on_unequip_pressed)

	EquipmentManager.equipment_changed.connect(_refresh_equipment_buttons)

# ── Slot buttons ──────────────────────────────────────────────────────────────

func _on_weapon_pressed() -> void: _open_picker(EquipmentItem.Slot.WEAPON, "Weapons")
func _on_robe_pressed()   -> void: _open_picker(EquipmentItem.Slot.ROBE,   "Robes")
func _on_hat_pressed()    -> void: _open_picker(EquipmentItem.Slot.HAT,    "Hats")

# ── Picker ────────────────────────────────────────────────────────────────────

func _open_picker(slot: EquipmentItem.Slot, title: String) -> void:
	_current_picker_slot = slot
	picker_title.text = title
	item_grid.doEquipment(slot, true)
	item_picker.visible = true

func _close_picker() -> void:
	item_picker.visible = false

func _on_item_selected(item: EquipmentItem) -> void:
	EquipmentManager.equip(item)
	_close_picker()

func _on_unequip_pressed(_slot: EquipmentItem.Slot) -> void:
	EquipmentManager.unequip(_current_picker_slot)
	_close_picker()

# ── Refresh ───────────────────────────────────────────────────────────────────

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
