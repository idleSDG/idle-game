class_name ItemGrid extends Node

#signal ingredient_pressed(item : Ingredient)
signal equipment_pressed(item : EquipmentItem)
signal unequip_pressed(slot : EquipmentItem.Slot)
signal item_selected(item : EquipmentItem)  # fired on tap, no equip yet

@onready var buttonBase = $Button
@onready var grid = $"."

var gridItems = []
var _current_slot : EquipmentItem.Slot

func _ready():
	pass

func empty_grid():
	for item in gridItems:
		item.queue_free()
	gridItems = []

func doEquipment(slot : EquipmentItem.Slot, 
	show_unequip : bool = false, show_highlight : bool = false):
	empty_grid()
	_current_slot = slot

	if show_unequip:
		var unequipButton = buttonBase

		var icon_node = unequipButton.get_node("Icon")
		icon_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_node.offset_bottom = -30

		unequipButton.visible = true
		unequipButton.add_theme_font_size_override("font_size", 128)
		unequipButton.pressed.connect(func(): unequip_pressed.emit(slot))

	var equipped = EquipmentManager.get_equipped(slot)
	var list = PlayerInventory.equipment
	for item in list:
		if item.slot == slot:
			var newButton = buttonBase.duplicate()
			
			var icon_node = newButton.get_node("Icon")
			icon_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon_node.offset_left = 20
			icon_node.offset_top = 20
			icon_node.offset_right = -20
			icon_node.offset_bottom = -60

			newButton.visible = true
			newButton.icon = null
			grid.add_child(newButton)
			gridItems.append(newButton)

			if item.icon:
					newButton.icon = item.icon
			elif slot == EquipmentItem.Slot.WEAPON:
					newButton.icon = load("res://assets/icons/staff.png")
			elif slot == EquipmentItem.Slot.ROBE:
					newButton.icon = load("res://assets/icons/robe.png")
			else:
					newButton.icon = load("res://assets/icons/hat.png")

			if equipped != null and item == equipped and show_highlight:
				newButton.show_highlight = true
				
			newButton.pressed.connect(func():
				equipment_pressed.emit(item)
				item_selected.emit(item)
			)

			newButton.button_up.connect(func():
				icon_node.offset_left = 20
				icon_node.offset_top = 20
				icon_node.offset_right = -20
				icon_node.offset_bottom = -60
			)

func inv_equipment_Button_Pressed(item : EquipmentItem):
	equipment_pressed.emit(item)
	doEquipment(item.slot)

func _on_hats_pressed() -> void:
	doEquipment(EquipmentItem.Slot.HAT)

func _on_robes_pressed() -> void:
	doEquipment(EquipmentItem.Slot.ROBE)

func _on_weapons_pressed() -> void:
	doEquipment(EquipmentItem.Slot.WEAPON)

func _on_potions_pressed() -> void:
	pass
