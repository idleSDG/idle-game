extends Node

@onready var weapon_btn       : Button         = $CanvasLayer/HSplit/RightVBox/EquipSection/WeaponSlotBtn
@onready var robe_btn         : Button         = $CanvasLayer/HSplit/RightVBox/EquipSection/RobeSlotBtn
@onready var hat_btn          : Button         = $CanvasLayer/HSplit/RightVBox/EquipSection/HatSlotBtn
@onready var stat_bonus_label : Label          = $CanvasLayer/HSplit/RightVBox/EquipSection/StatBonusLabel
@onready var skin_panel       : SkinColorPanel = $CanvasLayer/HSplit/RightVBox/CosmeticsSection/SkinColorPanel

# Item picker
@onready var item_picker      : Control  = $CanvasLayer/ItemPicker
@onready var item_grid        : ItemGrid = $CanvasLayer/ItemPicker/PanelContainer/VBox/ItemGrid
@onready var picker_title     : Label    = $CanvasLayer/ItemPicker/PanelContainer/VBox/PickerTitle
@onready var picker_close_btn : Button   = $CanvasLayer/ItemPicker/PanelContainer/VBox/HBox/CloseBtn
@onready var picker_equip_btn : Button   = $CanvasLayer/ItemPicker/PanelContainer/VBox/HBox/EquipBtn
@onready var picker_info_lbl  : Label    = $CanvasLayer/ItemPicker/PanelContainer/VBox/InfoLabel

var _current_picker_slot : EquipmentItem.Slot
var _selected_item : EquipmentItem = null

func _ready() -> void:
	_refresh_equipment_buttons()
	item_picker.visible = false
	picker_equip_btn.disabled = true  # nothing selected yet

	weapon_btn.pressed.connect(_on_weapon_pressed)
	robe_btn.pressed.connect(_on_robe_pressed)
	hat_btn.pressed.connect(_on_hat_pressed)

	skin_panel.changed.connect(_on_skin_color_changed)
	picker_close_btn.pressed.connect(_close_picker)
	picker_equip_btn.pressed.connect(_on_equip_pressed)

	item_grid.item_selected.connect(_on_item_selected)
	item_grid.unequip_pressed.connect(_on_unequip_pressed)

	EquipmentManager.equipment_changed.connect(_refresh_equipment_buttons)

# Slot buttons

func _on_weapon_pressed() -> void: _open_picker(EquipmentItem.Slot.WEAPON, "Staffs")
func _on_robe_pressed() -> void: _open_picker(EquipmentItem.Slot.ROBE, "Robes")
func _on_hat_pressed() -> void: _open_picker(EquipmentItem.Slot.HAT,"Hats")

# Picker

func _open_picker(slot: EquipmentItem.Slot, title: String) -> void:
	_current_picker_slot = slot
	_selected_item = null
	picker_title.text = title
	picker_info_lbl.text = ""
	picker_equip_btn.disabled = true
	item_grid.doEquipment(slot, true, true)
	item_picker.visible = true

func _close_picker() -> void:
	_selected_item = null
	item_picker.visible = false

func _on_item_selected(item: EquipmentItem) -> void:
	var equipped = EquipmentManager.get_equipped(_current_picker_slot)
	_show_item_info(item)
 
	# Already equipped — show info but don't enable equip button
	if equipped != null and item == equipped:
		picker_equip_btn.disabled = true
		return
 
	_selected_item = item
	picker_equip_btn.disabled = false

func _on_equip_pressed() -> void:
	if _selected_item == null:
		return
	EquipmentManager.equip(_selected_item)
	_close_picker()

func _on_unequip_pressed(_slot: EquipmentItem.Slot) -> void:
	EquipmentManager.unequip(_current_picker_slot)
	_close_picker()

func _show_item_info(item: EquipmentItem) -> void:
	var info = item.item_name + "\n"
	if item.health_bonus_pct != 0:
		info += "Health +%d%%\n" % int(item.health_bonus_pct * 100)
	if item.attack_bonus_pct != 0:
		info += "Attack +%d%%\n" % int(item.attack_bonus_pct * 100)
	if item.defense_bonus_pct != 0:
		info += "Defense +%d%%\n" % int(item.defense_bonus_pct * 100)
	if item.crit_rate_bonus_pct != 0:
		info += "Crit rate +%d%%\n" % int(item.crit_rate_bonus_pct * 100)
	if item.crit_dmg_bonus_pct != 0:
		info += "Crit DMG +%d%%\n" % int(item.crit_dmg_bonus_pct * 100)
	if item.ingredient_gain_bonus_pct != 0:
		info += "Ingredient gain +%d%%\n" % int(item.ingredient_gain_bonus_pct * 100)
	picker_info_lbl.text = info.strip_edges()

func _refresh_equipment_buttons() -> void:
	var w = EquipmentManager.get_equipped(EquipmentItem.Slot.WEAPON)
	var r = EquipmentManager.get_equipped(EquipmentItem.Slot.ROBE)
	var h = EquipmentManager.get_equipped(EquipmentItem.Slot.HAT)

	weapon_btn.text = "Staff : " + (w.item_name if w else "None  [tap to equip]")
	robe_btn.text   = "Robe  : " + (r.item_name if r else "None  [tap to equip]")
	hat_btn.text    = "Hat   : " + (h.item_name if h else "None  [tap to equip]")

	#var bonuses = EquipmentManager.get_total_bonuses()
	#stat_bonus_label.text = "Attack +%d%%\nIngredient +%d%%\nCrit +%d%%" % [
		#bonuses["attack_pct"]    * 100,
		#bonuses["ingredient_gain_pct"] * 100,
		#bonuses["crit_rate_pct"]     * 100,
	#]

func _on_skin_color_changed(color: Color) -> void:
	PlayerAppearance.apply_skin_color(color)
