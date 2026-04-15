class_name ItemGrid extends Node

signal ingredient_pressed(item : Ingredient)
signal equipment_pressed(item : EquipmentItem)
signal unequip_pressed(slot : EquipmentItem.Slot)

@onready var buttonBase = $Button
@onready var grid = $"."

var gridItems = []

func _ready():
	doIngredients()

func empty_grid():
	for item in gridItems:
		item.queue_free()
	gridItems = []

func doIngredients():
	empty_grid()
	var list = PlayerInventory.ingredients
	for item in list:
		var newButton = buttonBase.duplicate()
		newButton.visible = true
		grid.add_child(newButton)
		gridItems.append(newButton)
		newButton.pressed.connect(inv_ingredient_Button_Pressed.bind(list[item]))
		newButton.get_child(0).text = "x" + str(list[item].count)
		newButton.icon = load("res://assets/icons/kinetic.png")

func doEquipment(slot : EquipmentItem.Slot, show_unequip : bool = false):
	empty_grid()

	if show_unequip:
		var unequipButton = buttonBase.duplicate()
		unequipButton.visible = true
		unequipButton.text = "X"
		grid.add_child(unequipButton)
		gridItems.append(unequipButton)
		unequipButton.pressed.connect(func(): unequip_pressed.emit(slot))

	var equipped = EquipmentManager.get_equipped(slot)
	var list = PlayerInventory.equipment
	for item in list:
		if item.slot == slot:
			var newButton = buttonBase.duplicate()
			newButton.visible = true
			grid.add_child(newButton)
			gridItems.append(newButton)
			newButton.pressed.connect(inv_equipment_Button_Pressed.bind(item))

			if slot == EquipmentItem.Slot.WEAPON:
				newButton.icon = load("res://assets/icons/staff.png")
			elif slot == EquipmentItem.Slot.ROBE:
				newButton.icon = load("res://assets/icons/robe.png")
			else:
				newButton.icon = load("res://assets/icons/hat.png")

			# Green tint on currently equipped item
			if equipped != null and item == equipped:
				newButton.modulate = Color(0.4, 0.9, 0.4)

func inv_ingredient_Button_Pressed(item : Ingredient):
	ingredient_pressed.emit(item)
	doIngredients()

func inv_equipment_Button_Pressed(item : EquipmentItem):
	equipment_pressed.emit(item)
	doEquipment(item.slot)

func _on_ingredients_pressed() -> void:
	doIngredients()

func _on_hats_pressed() -> void:
	doEquipment(EquipmentItem.Slot.HAT)

func _on_robes_pressed() -> void:
	doEquipment(EquipmentItem.Slot.ROBE)

func _on_weapons_pressed() -> void:
	doEquipment(EquipmentItem.Slot.WEAPON)

func _on_potions_pressed() -> void:
	pass
