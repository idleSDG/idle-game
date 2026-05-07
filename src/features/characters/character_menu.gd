extends Node

# Stats section
@onready var hp_base_label         : Label = $CanvasLayer/HSplit/RightVBox/StatsSection/StatsGrid/HPBaseLabel
@onready var hp_final_label        : Label = $CanvasLayer/HSplit/RightVBox/StatsSection/StatsGrid/HPFinalLabel
@onready var atk_base_label        : Label = $CanvasLayer/HSplit/RightVBox/StatsSection/StatsGrid/ATKBaseLabel
@onready var atk_final_label       : Label = $CanvasLayer/HSplit/RightVBox/StatsSection/StatsGrid/ATKFinalLabel
@onready var def_base_label        : Label = $CanvasLayer/HSplit/RightVBox/StatsSection/StatsGrid/DEFBaseLabel
@onready var def_final_label       : Label = $CanvasLayer/HSplit/RightVBox/StatsSection/StatsGrid/DEFFinalLabel
@onready var crit_base_label       : Label = $CanvasLayer/HSplit/RightVBox/StatsSection/StatsGrid/CRBaseLabel
@onready var crit_final_label      : Label = $CanvasLayer/HSplit/RightVBox/StatsSection/StatsGrid/CRFinalLabel
@onready var critdmg_base_label    : Label = $CanvasLayer/HSplit/RightVBox/StatsSection/StatsGrid/CDMGBaseLabel
@onready var critdmg_final_label   : Label = $CanvasLayer/HSplit/RightVBox/StatsSection/StatsGrid/CDMGFinalLabel
@onready var ing_base_label        : Label = $CanvasLayer/HSplit/RightVBox/StatsSection/StatsGrid/IngBaseLabel
@onready var ing_final_label       : Label = $CanvasLayer/HSplit/RightVBox/StatsSection/StatsGrid/IngFinalLabel

# Equipment section
@onready var weapon_btn       : Button         = $CanvasLayer/HSplit/RightVBox/EquipSection/WeaponSlotBtn
@onready var robe_btn         : Button         = $CanvasLayer/HSplit/RightVBox/EquipSection/RobeSlotBtn
@onready var hat_btn          : Button         = $CanvasLayer/HSplit/RightVBox/EquipSection/HatSlotBtn
@onready var stat_bonus_label : Label          = $CanvasLayer/HSplit/RightVBox/EquipSection/StatBonusLabel
@onready var skin_panel       : SkinColorPanel = $CanvasLayer/HSplit/RightVBox/CosmeticsSection/SkinColorPanel

# Item picker
@onready var item_picker      : Control  = $CanvasLayer/ItemPicker
@onready var item_grid        : ItemGrid = $CanvasLayer/ItemPicker/PanelContainer/VBox/ItemGrid
@onready var picker_title     : Label    = $CanvasLayer/ItemPicker/PanelContainer/VBox/PickerTitle
@onready var picker_equip_btn : Button   = $CanvasLayer/ItemPicker/PanelContainer/VBox/HBox/EquipBtn
@onready var picker_info_lbl  : Label    = $CanvasLayer/ItemPicker/PanelContainer/VBox/InfoLabel

@onready var skill_background : Control = $CanvasLayer/SkillSelectionBackground

var _current_picker_slot : EquipmentItem.Slot
var _selected_item : EquipmentItem = null

const GREEN := Color(0.133, 0.827, 0.0)
const WHITE := Color(1.0, 1.0, 1.0)

func _ready() -> void:
	_refresh_equipment_buttons()
	_refresh_stats()
	item_picker.visible = false
	picker_equip_btn.disabled = true  # nothing selected yet

	weapon_btn.pressed.connect(_on_weapon_pressed)
	robe_btn.pressed.connect(_on_robe_pressed)
	hat_btn.pressed.connect(_on_hat_pressed)

	skin_panel.changed.connect(_on_skin_color_changed)
	picker_equip_btn.pressed.connect(_on_equip_pressed)

	item_grid.item_selected.connect(_on_item_selected)
	item_grid.unequip_pressed.connect(_on_unequip_pressed)

	item_picker.gui_input.connect(_on_picker_background_input)
	skill_background.gui_input.connect(_on_skill_background_input)

	EquipmentManager.equipment_changed.connect(_on_equipment_changed)
	PlayerProgress.leveled_up.connect(func(_o, _n): _refresh_stats())

# Stats
func _refresh_stats() -> void:
	var base  : CharacterStats = BattleVariables.GetPlayerBaseStatsAtLevel(PlayerProgress.level)
	var final : CharacterStats = BattleVariables.GetPlayer()
	var bonuses : Dictionary = EquipmentManager.get_total_bonuses()
	var final_ing : float = 1.0 + bonuses["ingredient_gain_pct"]

	_set_stat_row(hp_base_label, hp_final_label, 
		str(base.maxHealth), str(final.maxHealth), final.maxHealth != base.maxHealth)
	_set_stat_row(atk_base_label,atk_final_label, 
		str(base.attack), str(final.attack), final.attack != base.attack)
	_set_stat_row(def_base_label, def_final_label, 
		str(base.defense), str(final.defense), final.defense != base.defense)
	_set_stat_row(crit_base_label, crit_final_label, 
		"%.0f%%" % (base.critRate * 100), "%.0f%%" % (final.critRate * 100), final.critRate  != base.critRate)
	_set_stat_row(critdmg_base_label, critdmg_final_label, 
		"%.0f%%" % ((1.0+base.critDMG) * 100), "%.0f%%" % ((1.0+final.critDMG) * 100), final.critDMG != base.critDMG)
	_set_stat_row(ing_base_label, ing_final_label, 
		"100%", "%d%%" % int(final_ing * 100), final_ing != 1.0)

func _set_stat_row(base_lbl: Label, final_lbl: Label, base_val: String, final_val: String, boosted: bool) -> void:
	base_lbl.text      = base_val
	final_lbl.text     = final_val
	final_lbl.modulate = GREEN if boosted else WHITE

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

func _on_picker_background_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_close_picker()

func _on_skill_background_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_close_skill_selection()

func _close_skill_selection() -> void:
	skill_background.visible = false
	# Reset skill grid state
	var skill_grid : SkillGrid = $CanvasLayer/SkillSelectionBackground/SkillSelection/ScrollContainer/MarginContainer/SkillGrid
	skill_grid.currentSelection = -1
	skill_grid.doSkills()

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

func _on_skin_color_changed(color: Color) -> void:
	PlayerAppearance.apply_skin_color(color)
	
func _on_equipment_changed() -> void:
	_refresh_equipment_buttons()
	_refresh_stats()
