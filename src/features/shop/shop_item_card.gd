class_name ShopItemCard
extends PanelContainer

signal buy_pressed(item: EquipmentItem)

@onready var icon_rect: TextureRect = %Icon
@onready var name_label: Label = %NameLabel
@onready var stats_label: Label = %StatsLabel
@onready var buy_button: TextIconButton = %BuyButton
@onready var owned_label: Label = %OwnedLabel

var _item: EquipmentItem


func setup(item: EquipmentItem) -> void:
	_item = item
	name_label.text = item.item_name
	buy_button.button_text = str(item.cost)
	stats_label.text = _build_stats_text(item)

	match item.slot:
		EquipmentItem.Slot.WEAPON:
			icon_rect.texture = load("res://assets/icons/staff_icon.tres")
		EquipmentItem.Slot.ROBE:
			icon_rect.texture = load("res://assets/icons/robe_icon.tres")
		EquipmentItem.Slot.HAT:
			icon_rect.texture = load("res://assets/icons/hat_icon.tres")

	_refresh_state()

	buy_button.pressed.connect(_on_buy_pressed)
	PlayerInventory.money_changed.connect(_on_money_changed)
	PlayerInventory.item_purchased.connect(_on_item_purchased)


func _build_stats_text(item: EquipmentItem) -> String:
	var text = ""
	if item.health_bonus_pct > 0.001:
		text += "HP +%d%%\n" % int(item.health_bonus_pct * 100)
	if item.attack_bonus_pct > 0.001:
		text += "ATK +%d%%\n" % int(item.attack_bonus_pct * 100)
	if item.defense_bonus_pct > 0.001:
		text += "DEF +%d%%\n" % int(item.defense_bonus_pct * 100)
	if item.crit_rate_bonus_pct > 0.001:
		text += "Crit Rate +%d%%\n" % int(item.crit_rate_bonus_pct * 100)
	if item.crit_dmg_bonus_pct > 0.001:
		text += "Crit DMG +%d%%\n" % int(item.crit_dmg_bonus_pct * 100)
	if item.ingredient_gain_bonus_pct > 0.001:
		text += "Ingredient +%d%%\n" % int(item.ingredient_gain_bonus_pct * 100)
	return text.strip_edges()


func _refresh_state() -> void:
	var owned: bool = ShopCatalogue.is_owned(_item)
	var afford: bool = PlayerInventory.money >= _item.cost

	owned_label.visible = owned
	buy_button.visible = not owned
	buy_button.button_is_disabled = not afford

	# Green when affordable, default when not
	if afford:
		buy_button.text_color = Color(0.133, 0.827, 0.0)
	else:
		buy_button.text_color = Color(0, 0, 0)


func _on_buy_pressed() -> void:
	print("a")
	buy_pressed.emit(_item)


func _on_money_changed(_money: int) -> void:
	_refresh_state()


func _on_item_purchased(_purchased_item: EquipmentItem) -> void:
	_refresh_state()
