extends Node

# Stats labels
@onready var hp_final_label      : Label = $CanvasLayer/Background/VBox/HBoxBottom/Stats/StatsSection/Margin/Margin/Margin/StatsGrid/HPFinalLabel
@onready var atk_final_label     : Label = $CanvasLayer/Background/VBox/HBoxBottom/Stats/StatsSection/Margin/Margin/Margin/StatsGrid/ATKFinalLabel
@onready var def_final_label     : Label = $CanvasLayer/Background/VBox/HBoxBottom/Stats/StatsSection/Margin/Margin/Margin/StatsGrid/DEFFinalLabel
@onready var crit_final_label    : Label = $CanvasLayer/Background/VBox/HBoxBottom/Stats/StatsSection/Margin/Margin/Margin/StatsGrid/CRFinalLabel
@onready var critdmg_final_label : Label = $CanvasLayer/Background/VBox/HBoxBottom/Stats/StatsSection/Margin/Margin/Margin/StatsGrid/CDMGFinalLabel
@onready var ing_final_label     : Label = $CanvasLayer/Background/VBox/HBoxBottom/Stats/StatsSection/Margin/Margin/Margin/StatsGrid/IngFinalLabel

# Equipment buttons
@onready var weapon_btn : Button = $CanvasLayer/Background/VBox/HBoxBottom/Equip/EquipSection/WeaponSlotBtn
@onready var robe_btn   : Button = $CanvasLayer/Background/VBox/HBoxBottom/Equip/EquipSection/RobeSlotBtn
@onready var hat_btn    : Button = $CanvasLayer/Background/VBox/HBoxBottom/Equip/EquipSection/HatSlotBtn

# Skin color
@onready var skin_btn          : Button        = $CanvasLayer/Background/VBox/HBoxTop/Char/VBox/Avatar/Margin/VBox/SkinBtn
@onready var skin_color_picker : Control       = $CanvasLayer/Background/SkinColorPicker
@onready var skin_close_btn    : TextureButton = $CanvasLayer/Background/SkinColorPicker/SkinColorPanel/MarginContainer/VBoxContainer/HBoxContainer/TextureButton
@onready var color_picker      : ColorPicker   = $CanvasLayer/Background/SkinColorPicker/SkinColorPanel/MarginContainer/VBoxContainer/ColorPicker
@onready var skin_color_panel  : PanelContainer = $CanvasLayer/Background/SkinColorPicker/SkinColorPanel

# Item picker popup
@onready var item_picker      : Control  = $CanvasLayer/Background/ItemPicker
@onready var item_grid        : ItemGrid = $CanvasLayer/Background/ItemPicker/PanelContainer/VBox/ItemGrid
@onready var picker_title     : Label    = $CanvasLayer/Background/ItemPicker/PanelContainer/VBox/PickerTitle
@onready var picker_equip_btn : Button   = $CanvasLayer/Background/ItemPicker/PanelContainer/VBox/HBox/EquipBtn
@onready var picker_info_lbl  : Label    = $CanvasLayer/Background/ItemPicker/PanelContainer/VBox/InfoLabel

# Skill selection popup
@onready var skill_background : Control = $CanvasLayer/Background/SkillSelectionBackground

var _current_picker_slot : EquipmentItem.Slot
var _selected_item       : EquipmentItem = null

const GREEN := Color(0.133, 0.827, 0.0)
const WHITE := Color(1.0,   1.0,   1.0)

func _ready() -> void:
	_refresh_equipment_buttons()
	_refresh_stats()

	item_picker.visible       = false
	skin_color_picker.visible = false
	picker_equip_btn.disabled = true

	weapon_btn.pressed.connect(_on_weapon_pressed)
	robe_btn.pressed.connect(_on_robe_pressed)
	hat_btn.pressed.connect(_on_hat_pressed)

	skin_btn.pressed.connect(_on_skin_btn_pressed)
	skin_close_btn.pressed.connect(_close_skin_picker)
	skin_color_picker.gui_input.connect(_on_skin_picker_background_input)
	color_picker.color_changed.connect(_on_skin_color_changed)

	picker_equip_btn.pressed.connect(_on_equip_pressed)
	item_grid.item_selected.connect(_on_item_selected)
	item_grid.unequip_pressed.connect(_on_unequip_pressed)

	item_picker.gui_input.connect(_on_picker_background_input)
	skill_background.gui_input.connect(_on_skill_background_input)

	EquipmentManager.equipment_changed.connect(_on_equipment_changed)
	PlayerProgress.leveled_up.connect(func(_o, _n): _refresh_stats())

# ── Stats ─────────────────────────────────────────────────────────────────────
func _refresh_stats() -> void:
	var base      : CharacterStats = BattleVariables.GetPlayerBaseStatsAtLevel(PlayerProgress.level)
	var final     : CharacterStats = BattleVariables.GetPlayer()
	var bonuses   : Dictionary     = EquipmentManager.get_total_bonuses()
	var final_ing : float          = 1.0 + bonuses["ingredient_gain_pct"]

	_set_stat(hp_final_label,      _fmt_int(final.maxHealth,        final.maxHealth  - base.maxHealth),  final.maxHealth  != base.maxHealth)
	_set_stat(atk_final_label,     _fmt_int(final.attack,           final.attack     - base.attack),     final.attack     != base.attack)
	_set_stat(def_final_label,     _fmt_int(final.defense,          final.defense    - base.defense),    final.defense    != base.defense)
	_set_stat(crit_final_label,    _fmt_pct(final.critRate,         final.critRate   - base.critRate),   final.critRate   != base.critRate)
	_set_stat(critdmg_final_label, _fmt_pct(1.0 + final.critDMG,   final.critDMG    - base.critDMG),    final.critDMG    != base.critDMG)
	_set_stat(ing_final_label,     _fmt_pct(final_ing,              bonuses["ingredient_gain_pct"]),     final_ing        != 1.0)

func _set_stat(lbl: Label, text: String, boosted: bool) -> void:
	lbl.text     = text
	lbl.modulate = GREEN if boosted else WHITE

func _fmt_int(final_val: int, delta: int) -> String:
	if delta == 0:
		return str(final_val)
	return "%d(+%d)" % [final_val, delta]

func _fmt_pct(final_val: float, delta: float) -> String:
	var f := int(final_val * 100)
	var d := int(delta     * 100)
	if d == 0:
		return "%d%%" % f
	return "%d%%(+%d)" % [f, d]

# ── Equipment ─────────────────────────────────────────────────────────────────
func _on_weapon_pressed() -> void: _open_picker(EquipmentItem.Slot.WEAPON, "Staffs")
func _on_robe_pressed()   -> void: _open_picker(EquipmentItem.Slot.ROBE,   "Robes")
func _on_hat_pressed()    -> void: _open_picker(EquipmentItem.Slot.HAT,    "Hats")

func _refresh_equipment_buttons() -> void:
	var w = EquipmentManager.get_equipped(EquipmentItem.Slot.WEAPON)
	var r = EquipmentManager.get_equipped(EquipmentItem.Slot.ROBE)
	var h = EquipmentManager.get_equipped(EquipmentItem.Slot.HAT)
	weapon_btn.text = "Staff: " + (w.item_name if w else "[tap to equip]")
	robe_btn.text   = "Robe: "  + (r.item_name if r else "[tap to equip]")
	hat_btn.text    = "Hat: "   + (h.item_name if h else "[tap to equip]")

# ── Item picker popup ─────────────────────────────────────────────────────────
func _open_picker(slot: EquipmentItem.Slot, title: String) -> void:
	_current_picker_slot      = slot
	_selected_item            = null
	picker_title.text         = title
	picker_info_lbl.text      = ""
	picker_equip_btn.disabled = true
	item_grid.doEquipment(slot, true, true)
	item_picker.visible = true

func _close_picker() -> void:
	_selected_item      = null
	item_picker.visible = false

func _on_picker_background_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_close_picker()

func _on_item_selected(item: EquipmentItem) -> void:
	var equipped = EquipmentManager.get_equipped(_current_picker_slot)
	_show_item_info(item)
	if equipped != null and item == equipped:
		picker_equip_btn.disabled = true
		return
	_selected_item            = item
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
	var info := item.item_name + "\n"
	if item.health_bonus_pct          != 0: info += "Health +%d%%\n"          % int(item.health_bonus_pct          * 100)
	if item.attack_bonus_pct          != 0: info += "Attack +%d%%\n"          % int(item.attack_bonus_pct          * 100)
	if item.defense_bonus_pct         != 0: info += "Defense +%d%%\n"         % int(item.defense_bonus_pct         * 100)
	if item.crit_rate_bonus_pct       != 0: info += "Crit Rate +%d%%\n"       % int(item.crit_rate_bonus_pct       * 100)
	if item.crit_dmg_bonus_pct        != 0: info += "Crit DMG +%d%%\n"        % int(item.crit_dmg_bonus_pct        * 100)
	if item.ingredient_gain_bonus_pct != 0: info += "Ingredient Gain +%d%%\n" % int(item.ingredient_gain_bonus_pct * 100)
	picker_info_lbl.text = info.strip_edges()

# ── Skill selection popup ─────────────────────────────────────────────────────
func _on_skill_background_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_close_skill_selection()

func _close_skill_selection() -> void:
	skill_background.visible = false
	var skill_grid : SkillGrid = $CanvasLayer/Background/SkillSelectionBackground/SkillSelection/ScrollContainer/MarginContainer/SkillGrid
	skill_grid.currentSelection = -1
	skill_grid.doSkills()

# ── Skin color popup ──────────────────────────────────────────────────────────
func _on_skin_btn_pressed() -> void:
	skin_color_picker.visible = true

func _close_skin_picker() -> void:
	skin_color_picker.visible = false

func _on_skin_picker_background_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if not skin_color_panel.get_global_rect().has_point(event.global_position):
					_close_skin_picker()

func _on_skin_color_changed(color: Color) -> void:
	PlayerAppearance.apply_skin_color(color)

# ── Shared ────────────────────────────────────────────────────────────────────
func _on_equipment_changed() -> void:
	_refresh_equipment_buttons()
	_refresh_stats()
