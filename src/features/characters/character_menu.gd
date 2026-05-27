extends Node

# Stats label
@onready var stats_names_label : RichTextLabel = $CanvasLayer/Background/VBox/HBoxBottom/Stats/StatsSection/Margin/Margin/Margin/HBoxContainer/StatsNames
@onready var stats_values_label : RichTextLabel = $CanvasLayer/Background/VBox/HBoxBottom/Stats/StatsSection/Margin/Margin/Margin/HBoxContainer/StatsValues

# Equipment buttons
@onready var weapon_btn : Button = $CanvasLayer/Background/VBox/HBoxBottom/Equip/EquipSection/WeaponSlotBtn
@onready var robe_btn : Button = $CanvasLayer/Background/VBox/HBoxBottom/Equip/EquipSection/RobeSlotBtn
@onready var hat_btn : Button = $CanvasLayer/Background/VBox/HBoxBottom/Equip/EquipSection/HatSlotBtn

# Skin color
@onready var skin_btn : Button = $CanvasLayer/Background/VBox/HBoxTop/Char/VBox/Avatar/Margin/VBox/SkinBtn
@onready var skin_color_picker : Control = $CanvasLayer/Background/SkinColorPicker
@onready var skin_close_btn : TextureButton = $CanvasLayer/Background/SkinColorPicker/SkinColorPanel/MarginContainer/VBoxContainer/HBoxContainer/TextureButton
@onready var color_picker : ColorPicker = $CanvasLayer/Background/SkinColorPicker/SkinColorPanel/MarginContainer/VBoxContainer/ColorPicker
@onready var skin_color_panel : PanelContainer = $CanvasLayer/Background/SkinColorPicker/SkinColorPanel

# Item picker popup
@onready var item_picker : Control = $CanvasLayer2/ItemPicker
@onready var item_grid : ItemGrid = $CanvasLayer2/ItemPicker/PanelContainer/VBox/ItemGrid
@onready var picker_title : Label = $CanvasLayer2/ItemPicker/PanelContainer/VBox/HBox/PickerTitle
@onready var picker_equip_btn : Button = $CanvasLayer2/ItemPicker/PanelContainer/VBox/EquipBtn
@onready var preview_icon : TextureRect = $CanvasLayer2/ItemPicker/PanelContainer/VBox/HBoxCurrent/TextureRect
@onready var preview_name : Label = $CanvasLayer2/ItemPicker/PanelContainer/VBox/HBoxCurrent/VBox/CurrentName
@onready var picker_info_lbl : RichTextLabel = $CanvasLayer2/ItemPicker/PanelContainer/VBox/HBoxCurrent/VBox/CurrentInfo
@onready var picker_close_btn : TextureButton = $CanvasLayer2/ItemPicker/PanelContainer/VBox/HBox/TextureButton

# Skill selection popup
@onready var skill_background : Control = $CanvasLayer2/SkillSelectionBackground
@onready var skill_slot_title : Label = $CanvasLayer2/SkillSelectionBackground/SkillSelection/ScrollContainer/VBox/HBox/SlotTitle
@onready var skill_close_btn : TextureButton = $CanvasLayer2/SkillSelectionBackground/SkillSelection/ScrollContainer/VBox/HBox/TextureButton
@onready var skill_grid : SkillGrid = $CanvasLayer2/SkillSelectionBackground/SkillSelection/ScrollContainer/VBox/MarginContainer/SkillGrid

var _current_picker_slot : EquipmentItem.Slot
var _selected_item : EquipmentItem = null

const GREEN := Color(0.133, 0.827, 0.0)
const WHITE := Color(1.0,   1.0,   1.0)

func _ready() -> void:
	_refresh_equipment_buttons()
	_refresh_stats()

	item_picker.visible  = false
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
	picker_close_btn.pressed.connect(_close_picker)

	item_picker.gui_input.connect(_on_picker_background_input)
	skill_background.gui_input.connect(_on_skill_background_input)
	skill_close_btn.pressed.connect(_close_skill_selection)

	EquipmentManager.equipment_changed.connect(_on_equipment_changed)
	PlayerProgress.leveled_up.connect(func(_o, _n): _refresh_stats())

# Stats
func _refresh_stats() -> void:
	var base : CharacterStats = BattleVariables.GetPlayerBaseStatsAtLevel(PlayerProgress.level)
	var final : CharacterStats = BattleVariables.GetPlayer()
	var bonuses : Dictionary = EquipmentManager.get_total_bonuses()
	var final_ing : float = 1.0 + bonuses["ingredient_gain_pct"]

	var names := ""
	var values := ""

	names += _name_row("res://assets/icons/icon_plus.png", "HP")
	values += _value_row(_fmt_int(final.maxHealth, final.maxHealth - base.maxHealth), final.maxHealth != base.maxHealth)

	names += _name_row("res://assets/icons/atk.png", "ATK")
	values += _value_row(_fmt_int(final.attack, final.attack - base.attack), final.attack != base.attack)

	names += _name_row("res://assets/icons/def.png", "DEF")
	values += _value_row(_fmt_int(final.defense, final.defense - base.defense), final.defense != base.defense)

	names += _name_row("res://assets/icons/crt.png", "Crit Rate")
	values += _value_row(_fmt_pct(final.critRate, final.critRate - base.critRate), final.critRate != base.critRate)

	names += _name_row("res://assets/icons/cdm.png", "Crit DMG")
	values += _value_row(_fmt_pct(1.0 + final.critDMG, final.critDMG - base.critDMG), final.critDMG != base.critDMG)

	names += _name_row("res://assets/icons/chr.png", "Ing Gain")
	values += _value_row(_fmt_pct(final_ing, bonuses["ingredient_gain_pct"]), final_ing  != 1.0)

	stats_names_label.text  = names
	stats_values_label.text = values

func _name_row(icon: String, stat_name: String) -> String:
	return "[font_size=32][img=32]%s[/img] %s[/font_size]\n" % [icon, stat_name]

func _value_row(value: String, boosted: bool) -> String:
	var color := "00d400" if boosted else "ffffff"
	return "[font_size=32][color=#%s]%s[/color][/font_size]\n" % [color, value]

func _set_stat(lbl: Label, text: String, boosted: bool) -> void:
	lbl.text = text
	lbl.modulate = GREEN if boosted else WHITE

func _fmt_int(final_val: int, delta: int) -> String:
	if delta == 0:
		return str(final_val)
	return "%d(+%d)" % [final_val, delta]

func _fmt_pct(final_val: float, delta: float) -> String:
	var f := int(final_val * 100)
	var d := int(delta * 100)
	if d == 0:
		return "%d%%" % f
	return "%d%%(+%d)" % [f, d]

# Equipment
func _on_weapon_pressed() -> void: _open_picker(EquipmentItem.Slot.WEAPON, "STAFFS")
func _on_robe_pressed() -> void: _open_picker(EquipmentItem.Slot.ROBE, "ROBES")
func _on_hat_pressed() -> void: _open_picker(EquipmentItem.Slot.HAT, "HATS")

func _refresh_equipment_buttons() -> void:
	var w = EquipmentManager.get_equipped(EquipmentItem.Slot.WEAPON)
	var r = EquipmentManager.get_equipped(EquipmentItem.Slot.ROBE)
	var h = EquipmentManager.get_equipped(EquipmentItem.Slot.HAT)
	weapon_btn.text = "Staff: " + (w.item_name if w else "[tap to equip]")
	robe_btn.text = "Robe: " + (r.item_name if r else "[tap to equip]")
	hat_btn.text = "Hat: " + (h.item_name if h else "[tap to equip]")

# Item picker popup
func _open_picker(slot: EquipmentItem.Slot, title: String) -> void:
	_current_picker_slot = slot
	_selected_item = null
	picker_title.text = title
	picker_info_lbl.text = ""
	preview_icon.texture = load("res://assets/icons/icon_question_mark.png")
	preview_name.text = "No item selected"
	picker_equip_btn.disabled = true
	item_grid.doEquipment(slot, true, true)
	item_picker.visible = true

func _close_picker() -> void:
	_selected_item  = null
	item_picker.visible = false

func _on_picker_background_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_close_picker()

func _on_item_selected(item: EquipmentItem) -> void:
	var equipped = EquipmentManager.get_equipped(_current_picker_slot)
	if _current_picker_slot == EquipmentItem.Slot.WEAPON:
		preview_icon.texture = load("res://assets/icons/staff.png")
	elif _current_picker_slot == EquipmentItem.Slot.ROBE:
		preview_icon.texture = load("res://assets/icons/robe.png")
	else:
		preview_icon.texture = load("res://assets/icons/hat.png")
	preview_name.text = item.item_name
	_show_item_info(item)
	if equipped != null and item == equipped:
		picker_equip_btn.disabled = true
		return
	_selected_item = item
	picker_equip_btn.disabled = false


func _show_item_info(item: EquipmentItem) -> void:
	var info := ""
	if item.health_bonus_pct != 0:
		info += "[img=32]res://assets/icons/icon_plus.png[/img] HP  +%d%%\n" % int(item.health_bonus_pct * 100)
	if item.attack_bonus_pct != 0:
		info += "[img=32]res://assets/icons/atk.png[/img] ATK  +%d%%\n" % int(item.attack_bonus_pct * 100)
	if item.defense_bonus_pct != 0:
		info += "[img=32]res://assets/icons/def.png[/img] DEF  +%d%%\n" % int(item.defense_bonus_pct * 100)
	if item.crit_rate_bonus_pct != 0:
		info += "[img=32]res://assets/icons/crt.png[/img] Crit Rate  +%d%%\n" % int(item.crit_rate_bonus_pct * 100)
	if item.crit_dmg_bonus_pct != 0:
		info += "[img=32]res://assets/icons/cdm.png[/img] Crit DMG  +%d%%\n" % int(item.crit_dmg_bonus_pct * 100)
	if item.ingredient_gain_bonus_pct != 0:
		info += "[img=32]res://assets/icons/chr.png[/img] Ing Gain  +%d%%\n" % int(item.ingredient_gain_bonus_pct * 100)
	picker_info_lbl.parse_bbcode("[font_size=30]" + info.strip_edges() + "[/font_size]")

func _on_equip_pressed() -> void:
	if _selected_item == null:
		return
	EquipmentManager.equip(_selected_item)
	_close_picker()

func _on_unequip_pressed(_slot: EquipmentItem.Slot) -> void:
	EquipmentManager.unequip(_current_picker_slot)
	_close_picker()

# Skill selection popup
func _on_skill_background_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_close_skill_selection()

func _close_skill_selection() -> void:
	skill_background.visible = false
	skill_grid.currentSelection = -1
	skill_grid.doSkills()
	skill_slot_title.text = ""

# Skin color popup
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

# Shared
func _on_equipment_changed() -> void:
	_refresh_equipment_buttons()
	_refresh_stats()
